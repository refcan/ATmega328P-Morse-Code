;;; parse_input.S 29/11/2017 Evangelos (Angel) Chatzaroulas
;;; File that looks through the input and determines what letter should be displayed

; including the standard symbol definitions of all ports
#include <avr/io.h>

;; import symbol definitions for the letter representations on the 7 segment display
#include "letters.S"

;; This subroutine converts the morse code pattern into its letter representation in the 7 segment display.
;; In particular it utilises a tree-like branching structure to intelligently parse the morse code pattern and end up at the corrent letter

;; Input:
;; r24 = the morse code pattern saved as a bit pattern where 1 is a dash and 0 is a dot
;; r25 = a pointer to bit in r24 where a new dot or a dash would be written. This also happens to be the size of the pattern.

;; Output:
;; r24 = 7 segment representation of the letter denoted by the morse code pattern. If invalid, displays a dash

.global parse_input
parse_input:
    ;; Error Handling
    cpi r25, 5     ; maximum length for a morse code letter is 4
    breq error

    cpi r25, 0
    breq letter_a

    ;; Parsing the input, by that I mean checking what pattern it has then jumping to appropriate letter
    sbrs r24, 0     ; Check if the first element is a dash
    rjmp s0         ; We're going to be using `s` at the start of labels and then 0 for dot 1 for dash according to dots / dashes
    rjmp s1

error:
    ldi r24, CHAR_ERROR ; Display the Error pattern to the display
    rjmp end

;; dot branch
s0: cpi r25, 1      ; if letter ends at 1 element (that's a dot)
    breq letter_e
    sbrs r24, 1
    rjmp s00
    rjmp s01
    
letter_e:
    ldi r24, CHAR_E
    rjmp end

s00: 
    cpi r25, 2     ; if letter ends at 2 elements (that are 2 dots)
    breq letter_i
    sbrs r24, 2
    rjmp s000
    rjmp s001

letter_i:
    ldi r24, CHAR_I
    rjmp end

s01:
    cpi r25, 2     ; if letter ends at 2 elements (that are a dot and a dash)
    breq letter_a
    sbrs r24, 2
    rjmp s010
    rjmp s011

letter_a:
    ldi r24, CHAR_A
    rjmp end

s000:
    cpi r25, 3      ; if letter ends at 3 elements (that are 3 dots)
    breq letter_s
    sbrs r24, 3
    rjmp letter_h   ; only the letter h has 4 dots at all, no branching beyond that needed
    rjmp letter_v   ; only the letter v has 3 dots and 1 dash at all

letter_s:
    ldi r24, CHAR_S
    rjmp end

letter_h:
    ldi r24, CHAR_H
    rjmp end

letter_v:
    ldi r24, CHAR_V
    rjmp end

s001:
    cpi r25, 3      ; if letter ends at 3 elements (that are 2 dots 1 dash)
    breq letter_u
    rjmp letter_f   ; if we've reached this line, the only letter possible beyond is F

letter_u:
    ldi r24, CHAR_U
    rjmp end

letter_f:
    ldi r24, CHAR_F
    rjmp end

s010:
    cpi r25, 3      ; if letter ends at 3 elements (that are 1 dot 1 dash 1 dot)
    breq letter_r
    rjmp letter_l   ; if we've reached this line, the only letter possible beyond is L

letter_r:
    ldi r24, CHAR_R
    rjmp end


letter_l:
    ldi r24, CHAR_L
    rjmp end

s011:
    cpi r25, 3      ; if letter ends at 3 elements (that are 1 dot 2 dashes)
    breq letter_w
    sbrs r24, 3
    rjmp letter_p   ; at dot-dash-dash-dot we have P
    rjmp letter_j   ; at dot-dash-dash-dash we have J

letter_w:
    ldi r24, CHAR_W
    rjmp end

letter_p:
    ldi r24, CHAR_P
    rjmp end

letter_j:
    ldi r24, CHAR_J
    rjmp end

;; dash branch
s1:
    cpi r25, 1      ; if letter only has a dash
    breq letter_t
    sbrs r24, 1
    rjmp s10
    rjmp s11

letter_t:
    ldi r24, CHAR_T
    rjmp end

s10:
    cpi r25, 2      ; if letter only has 2 elements (dash and dot)
    breq letter_n
    sbrs r24, 2
    rjmp s100
    rjmp s101

letter_n:
    ldi r24, CHAR_N
    rjmp end

s11:
    cpi r25, 2      ; if letter only has 2 elements (2 dashes)
    breq letter_m
    sbrs r24, 2
    rjmp s110
    rjmp letter_o   ; only letter o has 3 consecutive dashes at all

letter_m:
    ldi r24, CHAR_M
    rjmp end

letter_o:
    ldi r24, CHAR_O
    rjmp end

s100:
    cpi r25, 3      ; if letter ends at 3 elements (1 dash 2 dots)
    breq letter_d
    sbrs r24, 3
    rjmp letter_b   ; 1 dash 3 dots
    rjmp letter_x   ; 1 dash 2 dots 1 dash

letter_d:
    ldi r24, CHAR_D
    rjmp end

letter_b:
    ldi r24, CHAR_B
    rjmp end

letter_x:
    ldi r24, CHAR_X
    rjmp end

s101:
    cpi r25, 3      ; if letter ends at 3 elements (1 dash 1 dot 1 dash)
    breq letter_k
    sbrs r24, 3
    rjmp letter_c   ; 1 dash 1 dot 1 dash 1 dot
    rjmp letter_y   ; 1 dash 1 dot 2 dashes

letter_k:
    ldi r24, CHAR_K
    rjmp end

letter_c:
    ldi r24, CHAR_C
    rjmp end

letter_y:
    ldi r24, CHAR_Y
    rjmp end

s110:
    cpi r25, 3      ; if letter ends at 3 elements ( 2 dashes 1 dot )
    breq letter_g
    sbrs r24, 3
    rjmp letter_z
    rjmp letter_q

letter_g:
    ldi r24, CHAR_G
    rjmp end

letter_z:
    ldi r24, CHAR_Z
    rjmp end

letter_q:
    ldi r24, CHAR_Q
    rjmp end

end:
    ret