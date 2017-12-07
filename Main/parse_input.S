;;; parse_input.S 29/11/2017 Evangelos (Angel) Chatzaroulas
;;; File that looks through the input and determines what letter should be displayed
;;; REFERENCES:
;;; TODO
#include <avr/io.h>

;; import symbol definitions for the letter representations on the 7 segment display
#include "letters.S"

;; This subroutine converts the morse code pattern into its letter representation in the 7 segment display.
;; Particularly it uses a pseudo 2-dimensional table and loops through it until it finds the values it seeks, and then returns the appropriate letter in r24
;; If it can't find anything it returns the error pattern.

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
    push r30		; save Z reg low
	push r31        ; save Z reg hi

    clr r20         ; setting reg 20 to 0

    ;; loop through the table to find letter
loop:
    ldi r30, lo8(letter_table) ; make Z point to the table with the letters.
	ldi r31, hi8(letter_table)

    add r30, r20    ; r20 is the iterator but we're going to be using it as the original offset into the table as well.
    brcc 1f         ; if we have no overflow in low byte of Z pointer when adding the offset, continue
    inc r31         ; else add the overflow to the high byte of Z

1:  lpm r21, Z      ; load data from the table to r21 for comparison purposes, since we don't want to modify the iterator
    cp r21, r25     ; compare pattern length
    brne incr       ; if it's not what we're looking for go to incr label

    adiw r30, 26    ; if it did match what we're looking for, add 26 to the Z pointer* to go to the next pseudo row with the bit pattern values
    lpm r21, Z
    cp r21, r24     ; check if the bit pattern value is the same too
    brne incr

    ;; If this little segment is reached we've found what we're looking for
    adiw r30, 26    ; if we've found what we're looking for, go to the third pseudo row to get the 7segment representation
    lpm r24, Z      ; and load it in r24
    rjmp end        ; then end the subroutine

    ;; This label just handles what to do if we haven't found what we're looking for
incr:
    cpi r20, 25     ; check if this is the end of the loop and we haven't found anything (r20 counts from 0 to 25, so it counts 26 times in total)
    brne 1f
    ldi r24, CHAR_ERROR ; display error if we've iterated through the table and found nothing
    rjmp end        ; end the subroutine

1:  inc r20         ; increment r20 and then go through the loop again
    rjmp loop

end:
    ;; restoring the registers
    pop r31
    pop r30
    pop r21
    pop r20

    ret

;; * We are adding 26 to the current "index" (which is the Z pointer with the offset added) to get to the next pseudo-row
;; because since each row has 26 elements, to get to the smae "column" in th next pseudo-row you would move 25 elements from your current one

;; This will sort of me a pseudo 2 dimentional table with 3 rows and 26 columns (one for each letter)
;; First pseudo-row will have the size of the morse code pattern 
;; Second pseudo-row will be the value in hex if we think of the morse pattern as a bit pattern with 1 being dash 0 being dot
;; Third pseudo-row will be pointing to the 7seg representation
letter_table:
    .byte 2, 4, 4, 3, 1, 4, 3, 4, 2, 4, 3, 4, 2, 2, 3, 4, 4, 3, 3, 1, 3, 4, 3, 4, 4, 4
    .byte 0x2, 0x1, 0x5, 0x1, 0x0, 0x4, 0x3, 0x0, 0x0, 0xE, 0x5, 0x2, 0x3, 0x1, 0x7, 0x6, 0xB, 0x2, 0x0, 0x1, 0x4, 0x8, 0x6, 0x9, 0xD, 0x3
    .byte CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, CHAR_I, CHAR_J, CHAR_K, CHAR_L, CHAR_M, CHAR_N, CHAR_O, CHAR_P, CHAR_Q, CHAR_R, CHAR_S, CHAR_T, CHAR_U, CHAR_V, CHAR_W, CHAR_X, CHAR_Y, CHAR_Z