;;; parse_input.S 29/11/2017 Evangelos (Angel) Chatzaroulas
;;; File that looks through the input and determines what letter should be displayed
;;; REFERENCES:
;;; TODO
#include <avr/io.h>

;; import symbol definitions for the letter representations on the 7 segment display
#include "letters.S"

;; This subroutine converts the morse code pattern into its letter representation in the 7 segment display.

;; Input:
;; r24 = the morse code pattern saved as a bit pattern where 1 is a dash and 0 is a dot
;; r25 = a pointer to bit in r24 where a new dot or a dash would be written. This also happens to be the size of the pattern.

;; Output:
;; r24 = 7 segment representation of the letter denoted by the morse code pattern. If invalid, displays a dash

.global parse_input
parse_input:
    ;; saving the registers we'll be using in the subroutine
    push r20
    push r21
    push r22
    push r30		; save Z reg low
	push r31        ; save Z reg hi

    clr r20         ; setting reg 20 to 0

    ;; loop through the table to find letter
loop:
    ldi r30, lo8(letter_table) ; make Z point to the table with the digits.
	ldi r31, hi8(letter_table)

    mov r21, r20    ; r20 is an iterator, r21 will handle the offset

    add r30, r21    ; r21 is the offset into the table
    brcc 1f         ; if we have no overflow in low byte of Z pointer when adding the offset, continue
    inc r31         ; else add the overflow to the high byte of Z

1:  lpm r22, Z      ; load data from the table to r22 for comparison purposes
    cp r22, r25     ; compare pattern length
    brne incr       ; if it's not what we're looking for go to incr label

    subi r21, -26   ; add 26 to r21 to get to the second pseudo-row
    add r30, r21    ; adjust the Z pointer accordingly (add offset and handle the overflow)
    brcc 1f      
    inc r31

1:  lpm r22, Z
    cp r22, r24      ; check if the morse code value is the same too
    brne incr

    ;; if we've reached this segment, that means we've found what we're looking for, so it's time to output
    subi r21, -26   ; go to the third pseudo-row
    add r30, r21    ; adjust the Z pointer accordingly (add offset and handle the overflow)
    brcc 1f
    inc r31

1:  lpm r24, Z       ; load the 7 segment representation of the letter into r24
    rjmp end         ; end the subroutine

    ;; This label just handles what to do if we haven't found what we're looking for
incr:
    cpi r20, 25     ; check if this is the end of the loop and we haven't found anything
    brne 1f
    ldi r24, CHAR_ERROR ; display error if we've iterated through the table and found nothing
    rjmp end

1:  inc r20         ; increment r20 and then go through the loop again
    rjmp loop

end:
    ;; restoring the registers
    pop r31
    pop r30
    pop r22
    pop r21
    pop r20

    ret

;; This will sort of me a pseudo 2 dimentional table with 3 rows and 26 columns (one for each letter)
;; First pseudo-row will have the size of the morse code pattern 
;; Second pseudo-row will be the value in hex if we think of the morse pattern as a bit pattern with 1 being dash 0 being dot
;; Third pseudo-row will be pointing to the 7seg representation
letter_table:
    .byte 2, 4, 4, 3, 1, 4, 3, 4, 2, 4, 3, 4, 2, 2, 3, 4, 4, 3, 3, 1, 3, 4, 3, 4, 4, 4
    .byte 0x1, 0x8, 0xA, 0x4, 0x0, 0x2, 0x6, 0x0, 0x0, 0x7, 0x5, 0x4, 0x3, 0x2, 0x7, 0x6, 0xD, 0x2, 0x0, 0x1, 0x1, 0x1, 0x3, 0x9, 0xB, 0xC
    .byte CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, CHAR_I, CHAR_J, CHAR_K, CHAR_L, CHAR_M, CHAR_N, CHAR_O, CHAR_P, CHAR_Q, CHAR_R, CHAR_S, CHAR_T, CHAR_U, CHAR_V, CHAR_W, CHAR_X, CHAR_Y, CHAR_Z