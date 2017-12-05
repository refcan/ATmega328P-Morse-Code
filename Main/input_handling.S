;;; input_handling.S <date> <maintainerName(s)>
;;; File to handle the input (interrupts and timers!)
;;; REFERENCES:
;;; TODO
#define __SFR_OFFSET 0
	#include <avr/io.h>
	#include "letters.S"

;;; Constants (TODO: Might be redundant?)
	CPU_FREQ = 16000000
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

	GAP_DECISION_LIMIT = 4 * TICKS_PER_SEC / 10   ; 400ms decision limit between inter-signal and inter-letter gap
	INPUT_DECISION_LIMIT = 2 * TICKS_PER_SEC / 10 ; 200ms decision limit between dot and dash input | TODO: Might be redundant?

	BUTTON = 0

		.section .text	
		.global timer1_compa_isr  ; export symbol to overwrite weak
				; definition in init.S

;;; This is the start of the interrupt service routine:
timer1_compa_isr:			

	push r16	
	in r16, SREG		; save the status register.
	push r16

	;; check whether we are waiting for a button press or release:
	lds r16, TCCR1B
	sbrs r16, ICES1 	; skip if waiting for positive edge (ie for button release)
	rjmp awaiting_press

awaiting_release:
	;;  make sure also an overly long press is always recognised
	;;  as a long press, irrespective of a timer overrun:
	ser r19 		; using r19 as a flag to indicate a
				; timer overflow has occured.
	rjmp 1f

awaiting_press:	
	cpi r25, 0
	breq 2f
	rcall parse_input

2:	out PORTD, r24		; display whatever's loaded in r20

1:	clr r25
	;inc r25			; remnant of debugging bit pattern write
	pop r16
	out SREG, r16 		; restore status register
	pop r16
	
	reti

	.global timer1_cpt_isr
timer1_cpt_isr:

	push r8

	in r8, SREG 		; save the status register.
	push r8

	lds r8, ICR1L		; get the timer count when the capture event happened.
	lds r8, ICR1H           ; we discard the low part, only
				; interested in the high part, but
				; reading low byte is necessary to get
				; a correct high byte in ICR1H, see
				; documentation [ATmega328p] Section 15.11.7 p131 
	push r17				

	;; debounce button:

	mov r17,r19		;  If there is no timer-overflow (ie a
				;  very long button press and
	or r17,r8		;  ICR1H is still zero, then 
				;  less than 16ms have elapsed since
				;  last release or press
	breq debounce		;  and we do nothing

	clr r17
	sts TCNT1H, r17 	; reset timer, first writing the high byte to the latch
	sts TCNT1L, r17		; then the low byte -- Section 16.3 of [328] again.

	;; check whether we were looking for a positive or a negative edge:
	lds r17, TCCR1B
	sbrs  r17, ICES1	; skip next instruction if positive edge dedection.
	
	rjmp pressed		; we have a negative edge ie button
				; has been pressed

	;; positive edge, button has been released
	rcall released

	andi r17, ~(_BV(ICES1)) ; we have had positive edge, so next
				; time looking for negative edge
	rjmp end_isr

	
pressed:
	;; call depressed ; more code to execute, perhaps for the coursework?
	ori r17, _BV(ICES1)	; next time detect positive edge, ie a
				; button release.
	ldi r16, ALL_SEGS
	out PORTD, r16

end_isr:
	sts TCCR1B, r17 	; write r17 to TCCR1B to activate the
				; change in edge detection.
	
debounce:
	pop r17
	pop r8
	out SREG, r8		; restore status register
	pop r8

	reti

released:

	push r16

	cpi r25, 0		; if r25 is 1, reset r24
	brne 1f
	clr r24

1:	tst r19 		; Did we have a timer overflow
				; (ie more than TIMEOUT time since the
				; last released of the button?
	brne long_press		; if yes, then signal is a long
				; press in any case

	;; is the signal longer than INPUT_DECISION_LIMIT?
	ldi r16, INPUT_DECISION_LIMIT
	cp r8,r16
	brcs short_press
	
long_press:
	;ldi r20, CHAR_T
	rcall set_mask
	rjmp 1f

short_press:
	rjmp 1f

1:	inc r25
	pop r16
	clr r19			; clear overflow flag in case it was set
	ret

set_mask:
	push r0
	push r16
	push r2

	clr r0
	ldi r16, 0x1
	mov r2, r25

loop:
	cp r2, r0
	breq l_done
	add r16, r16 ; bit shift left
	dec r2
	rjmp loop

l_done:
	or r24, r16
	pop r2
	pop r16
	pop r0
 	ret 