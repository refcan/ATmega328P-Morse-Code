;;; group_14.S 24/11/2017 Arturo Medina,  Evangelos (Angel) Chatzaroulas
;;; The main file that contains setup for input / output and then idles waiting for interrupts
;;; REFERENCES:
;;; [ATmega328p] Section 15.11.7 p131 - http://www.atmel.com/Images/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf

; automatically subtracts 0x20 from I/O space addresses for compatibility
#define __SFR_OFFSET 0
; including the standard symbol definitions of all ports
#include <avr/io.h>
; import file with symbol definitions for the 7 segment display in order to set the correct pins as output in PORTD
#include "letters.S"

;;; Constants
	CPU_FREQ = 16000000
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

	GAP_DECISION_LIMIT = 4 * TICKS_PER_SEC / 10   ; 400ms decision limit between inter-signal and inter-letter gap
	INPUT_DECISION_LIMIT = 2 * TICKS_PER_SEC / 10 ; 200ms decision limit between dot and dash input | TODO: Might be redundant?

	BUTTON = 0

	.section .text
	.global main 		; declaring global label main so it can be used by init.S
main:
	;; I/O Setup
	ldi r16, ALL_SEGS	; Enable all segments for the 7 Segment display
	out DDRD, r16		; in PORT D
	sbi PORTB, BUTTON 	; Switch on the pull-up for the button.

	;; set up the timer ([ATmega328p], Section 15.11.1 (p126))
	clr r16
	sts TCCR1A, r16 	; setting timer output mode: no output

	ldi r16, GAP_DECISION_LIMIT	; load the decision limit between a inter-signal and inter-letter gap to the high byte of the Output Compare Register A for Timer/Counter 1
	sts OCR1AH, r16

	clr r16				; the low byte of this register does not concern us but we should write 0 to it regardless
	sts OCR1AL, r16		; Documentation  Reference: [ATmega328p] Section 15.11.6 p111
	
	;; Set up the interrupts
	ldi r16, _BV(ICIE1) | _BV(OCIE1A)	; enable the input capture interrupt and the output compare A match interrupt for timer1
	sts TIMSK1, r16		; Documentation Reference: [ATmega328p] Section 15.11.8 p112

	;; Eanble Noise Canceller, start timer in CTC mode and set prescaler to 1024 (in order)
	ldi r16,  _BV(ICNC1) | _BV(WGM12) | _BV(CS12) | _BV(CS10)
	sts TCCR1B, r16		; Documentation Reference: [ATmega328p] Section 15.11.2 p110

	clr r19				; using r19 as a flag to indicate a timer overflow has occured. Thus by default no overflow has happened and it's initialized at 0

	sei					; enable interrupts globally.
	
	ldi r24, CHAR_ERROR	; Load the error character to r24 to indicate there hasn't been any input, once the timer1 comparison interrupt kicks in it'll load in the display
	clr r25				; initialise r25 as 0
	
wait: rjmp wait 		; wait for interrupts forever
