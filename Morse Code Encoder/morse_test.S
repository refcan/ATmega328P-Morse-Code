#define __SFR_OFFSET 0
#include <avr/io.h>
#include "delay_cs.S"

;;; Constants
CPU_FREQ = 16000000
TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

DOT = TICKS_PER_SEC / 10    ; 100ms
DASH = 3 * DOT              ; 300ms
SIGNAL_GAP = DOT            ; 100ms
LETTER_GAP = 3 * DOT        ; 300ms
WORD_GAP  = 7 * DOT         ; 700ms


;;; variables to make our life easier
.def length = r6
.def sequence = r7
.def bitmask = r8

main:
    ldi r16, _BV(5)
    out DDRB, r16 ; set bit 5 of PORTB as output

main_loop:
    rcall word_loop
    rjmp main_loop  ; just loop the word for ever

word_loop:
    push r5
    push r30
    push r31

    ldi r30, lo8(message) ; loading the message to the Z pointer
    ldi r31, hi8(message)


;; loop to loop through the message and then send signal for each letter
letter_loop:
    lpm r5, Z+ ; load next letter
    cpi r5, 0 ; check if end character reached
    breq end_word_loop    ; if yes, end the loop
    rcall send_letter_signal
    rjmp letter_loop

end_word_loop: 
    pop r31 ; restoring the registers
    pop r30
    pop r5
    ret

;; Subroutine to send a signal for the letter
send_letter_signal:
    push r20
    push r24
    push r30 ; we're going to point the Z pointer to the letter_table, so save the previous value
    push r31

    ldi r30, lo8(letter_table)
    ldi r31, hi8(letter_table)
    
    add r30, r5    ; add the offset
    brcc 1f
    inc r31

1:  lpm length, Z
    adiw r30, 26    ; add 26 to the Z pointer to go to pseudo-row 2
    lpm sequence, Z
    rcall make_mask ; prepare a bitmask

loop:
    sbi PORTB, 5    ; turn on bit 5 of PORTB

    dec length
    lsr bitmask     ; shift the bitmask to the right one bit
    mov r20, sequence   ; load the sequence to register for comparison purposes

    and r20, bitmask
    cpi r20, 0      ; check if it's 0. If it is, the bit is NOT set. Else it is
    brne 1f         ; if it's not it's a dash

    ldi r24, DOT    ; else it's a dot
    rjmp 1f

1:  ldi r24, DASH

2:  rcall delay_cs

    cbi PORTB, 5    ; turn off bit 5 of PORTB

    ldi r24, SIGNAL_GAP
    rcall delay_cs

    cp length, zero
    breq end_signal
    rjmp loop

end_signal:
    ldi r24, LETTER_GAP + SIGNAL_GAP    ; interletter gap extended
    rcall delay_cs

    pop r31
    pop r30
    pop r24
    pop r20

    ret


;; Subroutine to prepare the bitmask
make_mask:
	;; Save the registers we'll be using
	push r17			; r17 will be an iterator
    
    ldi bitmask, 0x1    ; intialise the mask with 1 (0000 0001)
    mov r17, length     ; load the length to the iterator

mask_loop:
    cpi r17, 0          ; if we don't need to shift anymore
    breq done           ; we're done
    lsl bitmask         ; else do logical shift left on the mask
    dec r17             ; decrement the iterator
    rjmp mask_loop

done:
    pop r17             ; restoring the register
 	ret

message:
.byte "ET"

;; a table to hold the length and bit pattern of a letter, starting from A to Z
letter_table:
.byte 2, 4, 4, 3, 1, 4, 3, 4, 2, 4, 3, 4, 2, 2, 3, 4, 4, 3, 3, 1, 3, 4, 3, 4, 4, 4
.byte 0x2, 0x1, 0x5, 0x1, 0x0, 0x4, 0x3, 0x0, 0x0, 0xE, 0x5, 0x2, 0x3, 0x1, 0x7, 0x6, 0xB, 0x2, 0x0, 0x1, 0x4, 0x8, 0x6, 0x9, 0xD, 0x3