;;; input_handling.S 4/12/2017 Arturo Medina, Evangelos (Angel) Chatzaroulas
;;; File to handle the button input using timers and interrupts
;;; REFERENCES:
;;; [ATmega328p] Section 15.11.7 p131 - http://www.atmel.com/Images/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf

; automatically subtracts 0x20 from I/O space addresses for compatibility
#define __SFR_OFFSET 0
; including the standard symbol definitions of all ports
#include <avr/io.h>
; import file with symbol definitions for the 7 segment display in order to turn off the display when the button is pressed
#include "letters.S"

;;; Constants
	CPU_FREQ = 16000000	; the frequency of the  CPU (16MHz)
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

	INPUT_DECISION_LIMIT = 2 * TICKS_PER_SEC / 10 ; 200ms decision limit between dot and dash input

	BUTTON = 0			; the bit of the button for PORTB

		.global timer1_compa_isr  ; exporting the symbol to overwrite .weak definition in init.S
timer1_compa_isr:			
	;; Saving the registers we'll be using
	push r16	
	in r16, SREG		; save the status register
	push r16

	;; a check to handle if we're waiting for a press or release
	lds r16, TCCR1B		; load the Timer/Counter 1 control Register B to r16 to check it
	sbrs r16, ICES1 	; in that register check if the last edge was a rising edge. If so, we're waiting for a button release
	rjmp awaiting_press	; else we're waiting for a button press

awaiting_release:
	;; If we had a timer comparison interrupt while the button is still pressed, we have an overly long press, but that's still a long press regardless.
	ser r19 			; as mentioned previously r19 is used as a flag to check if we had a timer overflow
						; we just did, so we set all bits of it to 1.
	rjmp 1f

awaiting_press:	
	;; If we had a timer comparison interrupt and we're waiting for a press, that means we had 400ms or more pass since the last release.
	;; In this case we're going to display a letter on the display
	cpi r25, 0			; if the length of the morse code sequence is 0, 
	breq 2f				; no need to do anything, r24 should hold the last letter input
	rcall parse_input	; else, if it's not 0, we've had a new input, time to parse it

2:	out PORTD, r24		; display whatever's loaded in r24, either the last letter unchanged, or a newly loaded letter
	clr r25				; in either case reset the length of the sequence to 0

	;; Restore the registers to their previous values
1:	pop r16
	out SREG, r16 		; restore status register
	pop r16
	
	reti

	.global timer1_cpt_isr	; exporting the symbol to overwrite .weak definition in init.S
timer1_cpt_isr:
	;; Saving the registers we'll be using
	push r8
	in r8, SREG 		; save the status register.
	push r8
	lds r8, ICR1L		; load the low part of the timer, only to discard it, we need to read it first to get accurate high byte value
	lds r8, ICR1H       ; load the high part, the one we're actually interested in
						; Documentation Reference: [ATmega328p] Section 15.11.7 p112
	push r17				

	;; Debounce
	mov r17, r19		; load our timer overflow flag to r17 for comparison purposes, it should be 0 and we're using it for that purpose
	or r17, r8			; Basically check if the high part of the timer (stored in r8) is 0. If it is, that means less than 16 ms have passed since last press or release, since
						; 1 tick in high part of the timer is roughly 16ms.
	breq debounce		; If that's the case, then we go to the debounce label, which essentially just returns from the interrupt without doing anything

	clr r17				; set r17 to 0
	sts TCNT1H, r17 	; and then set it to the timer, to reset it, saving to the high part first
	sts TCNT1L, r17		; and then the lower one. Documentation reference: [ATmega328p] Section 15.5 p95

	;; a check to handle if we're waiting for a press or release (further explanation same as in timer1_compa_isr)
	lds r17, TCCR1B
	sbrs r17, ICES1	
	rjmp pressed		; since the button follows inverse logic, if we had a negative edge it was pressed

	rcall released		; if not, it was released
	andi r17, ~(_BV(ICES1)) ; since it was released, next time look for a negative edge
	rjmp end_isr

pressed:
	ori r17, _BV(ICES1)	; since it was pressed, next time look for a positive edge
	ldi r16, ALL_SEGS	; We want to turn off the display when the button is pressed and a morse code pattern is being input
	out PORTD, r16

end_isr:
	sts TCCR1B, r17 	; write r17's value in TTCR1B to change the edge detection properly

	;; Basically just pop registers we used and return from the interrupt. Purpose of the extra debounce label is so we can exit if the time was lower than 16ms
debounce:
	;; Restore the registers we used
	pop r17
	pop r8
	out SREG, r8		; restore status register
	pop r8
	reti

released:
	;; Save the register we'll be using
	push r16

	cpi r25, 0			; if r25 is 0, we have a new pattern, reset r24
	brne 1f
	clr r24

1:	tst r19 			; check if we had an overflow (handled by timer1_compa_isr)
	brne dash			; If we're here and had an overflow, overflow happened while the button was pressed, which would make it a very long press, but still a dash

	ldi r16, INPUT_DECISION_LIMIT	; Load the input decision limit in r16 for comparison purposes
	cp r8, r16			; compare the timer value to decision limit
	brcs dot			; if it was lower, it's a dot
	
dash:					; else it was a dash. Label used so we can get to it if we had an overflow
	rcall set_mask		; If we had a dash, we should save a 1 to r24 on the correct position. We'll leave it up to set_mask to do that.
	rjmp 1f

dot:
	rjmp 1f				; Considering we represent a dot as a 0 in a bit pattern, nothing to do here.

1:	inc r25				; Either case increase the length of the sequence from whatever it was
	;; Restore registers we used
	pop r16
	clr r19				; clear overflow flag, just in case we had one
	ret


;; Subroutine to handle setting the 1 in the correct position on the bit pattern register (r24) using a bitmask.
;; Essentially we construct a bitmask based on r25, then using an OR operation with the mask set a bit in r24
set_mask:
	;; Save the registers we'll be using
	push r16			; r16 will be the bitmask
	push r17			; r17 will be an iterator

	ldi r16, 0x1		; load 1 (0000 0001) in r16 to initalise the bitmask
	mov r17, r25		; load r25's value in the iterator

loop:
	cpi r17, 0			; if the bit we must set 1 to is 0, or r17 has been decremented enough times so no more shifting is needed
	breq l_done			; we're done
	lsl r16				; else do bitwise left shift on r16, moving the 1 into place
	dec r17				; decrement r17
	rjmp loop

l_done:
	or r24, r16			; set a bit in r24 using OR with the bitmask

	;; Restore the registers we used
	pop r17
	pop r16
 	ret 
