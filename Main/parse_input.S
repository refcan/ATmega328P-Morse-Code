;;; parse_input.S <date> <maintainerName(s)>
;;; File to parse the input and display the right letter on screen
;;; REFERENCES:
;;; TODO
#include <avr/io.h>
#include "letters.S"

;; Convert a digit from some register into 7seg data
.global parse_input
parse_input:
    ;; saving the registers we'll be using
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
    subi r21, -26   ; add 26 to r21 to get to the second pseudo-row

    add r30, r21    ; r21 is the offset into the table
    brcc 1f         ; if we have no overflow in low byte of Z pointer, continue
    inc r31         ; else add the overflow to the high byte of Z

1:  lpm r22, Z      ; load data from the table to r22 for comparison purposes
    cp r22, r25     ; compare element length
    brne incr       ; if it's not what we're looking for go to incr label

    subi r21, -26   ; go to third pseudo-row
    add r30, r21    ; adjust the Z pointer accordingly
    brcc 1f      
    inc r31

1:  lpm r22, Z
    cp r22, r24      ; check if the morse code value is the same too
    brne incr

    rjmp display     ; if this line is reached we've found what we're looking for, time to display

incr:
    cpi r20, 26     ; check if this is the end of the loop and we haven't found anything
    brne 1f
    ldi r24, CHAR_ERROR ; display error if we've iterated through the table and found nothing
    rjmp end

1:  inc r20         ; increment r20 and then go through the loop again
    rjmp loop

display:
    ldi r30, lo8(letter_table) ; Z pointer was altered to look through the table, reset it
	ldi r31, hi8(letter_table) 
    add r30, r20    ; add the offset
    brcc 1f
    inc r31

1:  lpm r24, Z
    rjmp end

end:
    ;; restoring the registers
    pop r31
    pop r30
    pop r22
    pop r21
    pop r20

    ret

;; This will sort of me a pseudo 2 dimentional table with 3 rows and 26 columns (one for each letter)
;; First pseudo-row will be pointing to the 7seg representation, 
;; second one to number of elements in the morse code pattern for it (plus one for comparison purposes with r25)
;; third pseudo-row will be the value in hex if we think of the morse pattern as a bit pattern with 1 being dash 0 being dot
letter_table:
    .byte CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, CHAR_I, CHAR_J, CHAR_K, CHAR_L, CHAR_M, CHAR_N, CHAR_O, CHAR_P, CHAR_Q, CHAR_R, CHAR_S, CHAR_T, CHAR_U, CHAR_V, CHAR_W, CHAR_X, CHAR_Y, CHAR_Z
    .byte 3, 5, 5, 4, 2, 5, 4, 5, 3, 5, 4, 5, 3, 3, 4, 5, 5, 4, 4, 2, 4, 5, 4, 5, 5, 5
    .byte 0x1, 0x8, 0xA, 0x4, 0x0, 0x2, 0x6, 0x0, 0x0, 0x7, 0x5, 0x4, 0x3, 0x2, 0x7, 0x6, 0xD, 0x2, 0x0, 0x1, 0x1, 0x1, 0x3, 0x9, 0xB, 0xC