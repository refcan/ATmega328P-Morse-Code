;;; input_handling.S <date> <maintainerName(s)>
;;; File to handle the input (interrupts and timers!)
;;; REFERENCES:
;;; TODO

#include "parse_input.S"

;;; Constants (TODO: Might be redundant?)
	CPU_FREQ = 16000000
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second
	INPUT_DECISION_LIMIT = 2 * TICKS_PER_SEC / 10 ; 200ms decision limit between dot and dash input

;;;; IMPLEMENTATION IDEA
;;;; -----------------------------------------------------------
;;;; 1 register for current input going on, 1 register for current bit in the other register
;;;; in cpt_isr, we are changing the bits accordingly as we go
;;;; increase bit every time
;;;; in compa_isr we tie things up and then call parse_input to display stuff.

;;; cTODO vvvvvvvvvvv
;;; This interrupt service routine is called whenever timer1 has
;;; counted up to match the value stored in OCA1, ie when more then
;;; GAP_DECISION_LIMIT time has elapses since the last button press or release.
	
	.global timer1_compa_isr  ; export the symbol
	
timer1_compa_isr:
                     ; TODO interrupt! This interrupt handles what happens when enough time has passed after last button press or release.
	push r16
	in r16, SREG
	push r16

	lds r16, TCCR1B
	sbrs, ICES1
	rjmp awaiting_press

awaiting_release:

	ser r19

	rjmp 1f

awaiting_press:

	ldi r16, _BV(BUTTON)
	out PORTB, r16

	pop r16
	out SREG, r16 	
	pop r16

	reti
;;; cTODO

    .global timer1_cpt_isr ; export the symbol

timer1_cpt_isr:
    nop                       ; TODO interrupt! Interrupt to time button presses

released:
    nop
    ;; here we parse button input, we'll check if press was long or short.
    ;; if long -> store 1 in bit, else nothing
    ;; either case increase bit tracking register