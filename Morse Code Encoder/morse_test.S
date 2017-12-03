#define __SFR_OFFSET 0
#include <avr/io.h>
#include "delay_cs.S"

;;; Constants
CPU_FREQ = 16000000
TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ; 1000ms or 1 second

DOT = TICKS_PER_SEC / 10
DASH = 3 * DOT
SIGNAL_GAP = DOT
LETTER_GAP = 3 * DOT
WORD_GAP  = 7 * DOT

main:
    ldi r16, _BV(5)
    out DDRB, r16 ; set bit 5 of PORTB as output

main_loop:
    rcall word_loop
    rjmp main_loop  ; just loop the word for ever

word_loop:
    push r1 ; pushing the registers we're going to be using
    push r5
    push r6
    push r7
    push r8
    push r24
    push r30
    push r31

    ldi r30, lo8(message) ; loading the message to the Z pointer
    ldi r31, hi8(message)

    ;;; variables to make our life easier
    .def zero = r1
    .def length = r6
    .def sequence = r7
    .def bitmask = r8

    clr zero ; set zero to, well, zero

;; loop to loop through the message and then send signal for each letter
letter_loop:
    lpm r5, Z+ ; load next letter
    cp r5, zero ; check if end character reached
    breq end    ; if yes, end the loop
    rcall send_letter_signal
    rjmp letter_loop

end_word_loop: 
    pop r31 ; restoring the registers
    pop r30
    pop r24
    pop r8
    pop r7
    pop r6
    pop r5
    pop r1
    ret

;; Bit of the code to send a signal for the letter
send_letter_signal:
    push r24
    push r30 ; we're going to point the Z pointer to the letter_table, so save the previous value
    push r31

    ldi r30, lo8(letter_table)
    ldi r31, hi8(letter_table)
    
    add r30, r5    ; add the offset
    brcc 1f
    inc r31

1:  lpm length, Z
    lpm sequence, Z+26

loop:
    sbi PORTB, 5    ; turn on bit 5 of portB
    dec length

    sbis sequence, length
    ldi r24, DOT
    ldi r24, DASH
    rcall delay_cs

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

    ret

message:
.db "ET"

;; a table to hold the length and bit pattern of a letter, starting from A to Z
letter_table:
.byte 2, 4, 4, 3, 1, 4, 3, 4, 2, 4, 3, 4, 2, 2, 3, 4, 4, 3, 1, 3, 4, 3, 4, 4, 4
.byte 0x1, 0x8, 0xA,  0x4, 0x0, 0x2, 0x6, 0x0, 0x0, 0x7, 0x5, 0x4, 0x3, 0x2, 0x7, 0x6, 0xD, 0x2, 0x0, 0x1, 0x1, 0x1, 0x3, 0x9, 0xB, 0xC