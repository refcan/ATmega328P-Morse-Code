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

	.global main 		; declaring main global, so it can be used in other files
main:
	;; Setting up the button
	sbi PORTB, BUTTON 	; DDRB0 an input by default, all we need to do is switch on the pull-up to be able to read button input since when button is pressed it sends a 0 signal.
	
	;; Setting up the timer
	clr r16
	sts TCCR1A, r16		; Timer1 Output mode: no output

	ldi r16, GAP_DECISION_LIMIT ; cTODO
	sts OCR1AH, r16				; cTODO

	clr r16						; cTODO
	sts OCR1AL, r16				; cTODO

	ldi r16, _BV(ICIE1) | _BV(OCIE1A) ; enable input capture interrupt and compare match interrupt on Timer1
	sts TIMSK1, r16

	ldi r16,  _BV(ICNC1) | _BV(CS12) | _BV(CS10) | _BV(WGM12) ; enable noise canceler, set time prescaler to 1024, start timer in CTC mode.
	sts TCCR1B, r16 ; TODO what is CTC mode

	;; Setting up the output
	ldi r24, ALL_SEGS
	out DDRD, r24 ; cTODO

	;; Additional Setup
	clr r19 ; We are using Register 19 to indicate whether or not a timer overflow has happened, therefore we initialise it by clearing it. 

	sei		; Global Interrupt Enable

wait: rjmp wait	; idling, waiting for interrupts to happen