;;;  YOUR CODE SHOULD GO INTO THIS FILE. TODO: del
;;;	PLEASE ADD YOUR OWN COMMENTED HEADER TODO: del

;;; group_14.S <date> <maintainerName(s)>
;;; The main file that contains setup for input / output and then idles
;;; REFERENCES:
;;; TODO

;;; just including the standard symbol definitions of all ports:
#define __SFR_OFFSET 0
#include <avr/io.h>
#include "letters.S"

;;; Constants
	CPU_FREQ = 16000000
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

	GAP_DECISION_LIMIT = 4 * TICKS_PER_SEC / 10   ; 400ms decision limit between inter-signal and inter-letter gap
	INPUT_DECISION_LIMIT = 2 * TICKS_PER_SEC / 10 ; 200ms decision limit between dot and dash input | TODO: Might be redundant?

	BUTTON = 0

;;; user code starts from here, as init.S ends with jmp main:
	.section .text
	.global main 		; declaring main global, so it can be used in other files
main:	
	;; Enable the bits for the 7 Segment display in PORT D
	ldi r16, ALL_SEGS
	out DDRD, r16

	sbi PORTB, BUTTON 	; switch on the pull-up for the button.

	;; set up the timer ([ATmega328p], Section 15.11.1 (p126))
	clr r16
	sts TCCR1A, r16 	; setting timer output mode: no output
				; pin used, normal counting up. 

	ldi r16, GAP_DECISION_LIMIT
	sts OCR1AH, r16

	clr r16
	sts OCR1AL, r16
	
	;; enable input capture interrupt (to time button presses) and
	;; timer overflow interrupt (the time-out to switch on the
	;; yellow LED:
	ldi r16, _BV(ICIE1) | _BV(OCIE1A)
	sts TIMSK1, r16

	;; enable noise canceller, set prescaler to 1024, and start
	;; timer in normal mode, [ATmega328p] section 12.11.2 (p128).
	ldi r16,  _BV(ICNC1) | _BV(WGM12) | _BV(CS12) | _BV(CS10)
	sts TCCR1B, r16

	clr r19			; reset overflow flag to defined state

	sei				; enable interrupts globally.
	ldi r16, CHAR_ERROR 	; turn on the error character for startup
	out PORTD, r16
	
wait:
	rjmp wait 		; wait for interrupts!
