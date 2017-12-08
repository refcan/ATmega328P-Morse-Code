;;; group_14.S 24/11/2017 Evangelos (Angel) Chatzaroulas
;;; Encodes the message in the string under the label message into morse code electrical signals.
;;; Meant to be used with another arduino running a morse code decoder and is connected to it through an octocoupler

; automatically subtracts 0x20 from I/O space addresses for compatibility
#define __SFR_OFFSET 0
; including the standard symbol definitions of all ports
#include <avr/io.h>

;;; Constants
DOT = 10                    ; The length of a dot in centiseconds (10cs == 100ms) since delay_cs is designed to accept a parameter in r24 in centiseconds.
DASH = 3 * DOT              ; 30cs / 3 dots
SIGNAL_GAP = DOT            ; 10cs / 1 dot
LETTER_GAP = 3 * DOT        ; 30cs / 3 dots
WORD_GAP = 7 * DOT	        ; 70cs / 7 dots

    .global main
main:
    ldi r16, _BV(5)
    out DDRB, r16 ; Set bit 5 of PORTB as output, which is pin 13.

;; The loop that will be eternally iterated through to keep printing the word
main_loop:
    rcall word_loop ; Calling the subroutine to encode a word
    rjmp main_loop  ; Just loop the word for ever

;; Subroutine to encode the "word" that's in the string under the message label.
;; We'll refer to the "word" in the string as the message
word_loop:
    ;; Saving the registers we'll use
    push r16
    push r30
    push r31

    ;; Pointing the Z pointer to the message
    ldi r30, lo8(message)
    ldi r31, hi8(message)

    ;; Note: A string is basically an array of characters represented by their ASCII values, stored in consecutive memory adresses, and the end character of a string is 0,
    ;; added automatically by the Assembler since we're using the .string Assembler pseudo-op.
    ;; This means we can think of the string as a table and use the Z pointer accordingly to iterate through it, just like we would a table of letters.

;; Loop to loop through the message and then send signal for each letter
letter_loop:
    lpm r16, Z+         ; Load the letter into r16 and then make the Z pointer point to the next letter
    cpi r16, 0          ; Check if end character reached
    breq end_word_loop  ; If yes, we have encoded the entire word
    rcall send_letter_signal    ; If not we will encode this specific letter
    rjmp letter_loop    ; and we'll go to the next letter

end_word_loop: 
    ;; Restoring the registers we have used
    pop r31
    pop r30
    pop r16
    ret

;; Subroutine to send a signal for the letter
send_letter_signal:
    ;; Saving the registers we'll use
    push r7
    push r20
    push r21
    push r22
    push r24
    push r30 ; we're going to point the Z pointer to the letter_table, so we'll save this too
    push r31

    ;; Pointing the Z pointer to the letter_table
    ldi r30, lo8(letter_table)
    ldi r31, hi8(letter_table)

    subi r16, 0x41  ; remove the value of A*, the first capital letter, to get the offset into the letter table.
    add r30, r16    ; add the offset
    brcc 1f
    inc r31

1:  lpm r20, Z      ; r20 will be the length of the bit pattern corresponding to the morse code pattern of a letter, if it starts from Bit 0 and 0 is a dot, 1 is a dash.
    adiw r30, 26    ; add 26 to the Z pointer to go to pseudo-row 2
    lpm r7, Z       ; r7 will be the bit pattern itself
    ldi r21, 0x1    ; prepare a bitmask on r21

loop:
    sbi PORTB, 5    ; turn on bit 5 of PORTB to start the signal

    dec r20         ; decrement the length, which we're kind of using as an iterator
    mov r22, r7     ; load the sequence to r22 for comparison purposes

    and r22, r21    ; Test the bitmask against the bit sequence using an AND operation
    cpi r22, 0      ; check if it's 0. If it is, the bit is NOT set. Else it is
    brne 1f         ; if it's not it's a dash

    ldi r24, DOT    ; else it's a dot
    rjmp 2f

1:  ldi r24, DASH

2:  rcall delay_cs  ; wait 100ms or 300ms depending on if we need to send a dot or a dash. How long we keep the e signal open determines if it's a dot or a dash to the decoder

    cbi PORTB, 5    ; turn off bit 5 of PORTB to end the signal

    ldi r24, SIGNAL_GAP ; Signal is done, let's wait SIGNAL_GAP ammount of time
    rcall delay_cs

    cpi r20, 0      ; check if the length is 0, as in if we're done with the bit sequence
    breq end_signal ; if so, we're ending the signal for the letter
    lsl r21         ; shift the bitmask to the left one bit so we can check the next bit next time
    rjmp loop

end_signal:
    ldi r24, LETTER_GAP + SIGNAL_GAP    ; wait LETTER_GAP time but extended by SIGNAL_GAP to be on the safe side
    rcall delay_cs

    ;; Restore all registers we've used
    pop r31
    pop r30
    pop r24
    pop r22
    pop r21
    pop r20
    pop r7

    ret
    
;; The message string
message:
    .string "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

;; a table to hold the length and bit pattern of a letter, starting from A to Z
letter_table:
    .byte 2, 4, 4, 3, 1, 4, 3, 4, 2, 4, 3, 4, 2, 2, 3, 4, 4, 3, 3, 1, 3, 4, 3, 4, 4, 4
    .byte 0x2, 0x1, 0x5, 0x1, 0x0, 0x4, 0x3, 0x0, 0x0, 0xE, 0x5, 0x2, 0x3, 0x1, 0x7, 0x6, 0xB, 0x2, 0x0, 0x1, 0x4, 0x8, 0x6, 0x9, 0xD, 0x3