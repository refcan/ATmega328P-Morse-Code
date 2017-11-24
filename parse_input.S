;;; parse_input.S <date> <maintainerName(s)>
;;; File to parse the input and display the right letter on screen
;;; REFERENCES:
;;; TODO

#include "letters.S"

.global parse_input

;; Convert a digit from some register intoo 7seg data
parse_input:

	ldi r30, lo8(letter_table) ; make Z point to the table with the digits.
	ldi r31, hi8(letter_table)

letter_table:
    ;; TABLE OF THE CHARACTERS: todo: fill them in
    .byte CHAR_E