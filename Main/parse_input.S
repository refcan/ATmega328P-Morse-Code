;;; parse_input.S <date> <maintainerName(s)>
;;; File to parse the input and display the right letter on screen
;;; REFERENCES:
;;; TODO

#include "letters.S"

.global parse_input

;; Convert a digit from some register into 7seg data
parse_input:

    ;; Error Handling
    cpi r25, 5     ; maximum length for a morse code letter is 4
    breq error

    ;; Parsing the input, by that I mean checking what pattern it has then jumping to appropriate letter
    sbis r24, 1     ; Check if the first element is a dash
    rjmp s0         ; We're going to be using `s` at the start of labels and then 0 for dot 1 for dash according to dots / dashes
    rjmp s1

;; dot branch
s0: cpi r25, 2      ; if letter ends at 1 element (that's a dot)
    breq letter_e
    sbis r24, 2
    rjmp s00
    rjmp s01
    
s00: 
    cpi r25, 3      ; if letter ends at 2 elements (that are 2 dots)
    breq letter_i
    sbis r24, 3
    rjmp s000
    rjmp s001

s01:
    cpi r25, 3      ; if letter ends at 2 elements (that are a dot and a dash)
    breq letter_a
    sbis r24, 3
    rjmp s010
    rjmp s011

s000:
    cpi r25, 4      ; if letter ends at 3 elements (that are 3 dots)
    breq letter_s
    sbis r24, 4
    rjmp letter_h   ; only the letter h has 4 dots at all, no branching beyond that needed
    rjmp letter_v   ; only the letter v has 3 dots and 1 dash at all

s001:
    cpi r25, 4      ; if letter ends at 3 elements (that are 2 dots 1 dash)
    breq letter_u
    rjmp letter_f   ; if we've reached this line, the only letter possible beyond is F

s010:
    cpi r25, 4      ; if letter ends at 3 elements (that are 1 dot 1 dash 1 dot)
    breq letter_r
    rjmp letter_l   ; if we've reached this line, the only letter possible beyond is L

s011:
    cpi r25, 4      ; if letter ends at 3 elements (that are 1 dot 2 dashes)
    breq letter_w
    sbis r24, 4
    rjmp letter_p   ; at dot-dash-dash-dot we have P
    rjmp letter_j   ; at dot-dash-dash-dash we have J

;; dash branch
s1:
    cpi r25, 2      ; if letter only has a dash
    breq letter_t
    sbis r24, 2
    rjmp s10
    rjmp s11

s10:
    cpi r25, 3      ; if letter only has 2 elements (dash and dot)
    breq letter_n
    sbis r24, 3
    rjmp s100
    rjmp s101

s11:
    cpi r25, 3      ; if letter only has 2 elements (2 dashes)
    breq letter_m
    sbis r24, 3
    rjmp s110
    rjmp letter_o   ; only letter o has 3 consecutive dashes at all

s100:
    cpi r25, 4      ; if letter ends at 3 elements (1 dash 2 dots)
    breq letter_d
    sbis r24, 4
    rjmp letter_b   ; 1 dash 3 dots
    rjmp letter_x   ; 1 dash 2 dots 1 dash

s101:
    cpi r25, 4      ; if letter ends at 3 elements (1 dash 1 dot 1 dash)
    breq letter_k
    sbis r24, 4
    rjmp letter_c   ; 1 dash 1 dot 1 dash 1 dot
    rjmp letter_y   ; 1 dash 1 dot 2 dashes

s110:
    cpi r25, 4      ; if letter ends at 3 elements ( 2 dashes 1 dot )
    breq letter_g
    sbis r24, 4
    breq letter_z
    breq letter_q

;; Loading the characters to the display
letter_a:
    lpm r24, CHAR_A
    rjmp end

letter_b:
    lpm r24, CHAR_B
    rjmp end

letter_c:
    lpm r24, CHAR_C
    rjmp end

letter_d:
    lpm r24, CHAR_D
    rjmp end

letter_e:
    lpm r24, CHAR_E
    rjmp end

letter_f:
    lpm r24, CHAR_F
    rjmp end

letter_g:
    lpm r24, CHAR_G
    rjmp end

letter_h:
    lpm r24, CHAR_H
    rjmp end

letter_i:
    lpm r24, CHAR_I
    rjmp end

letter_j:
    lpm r24, CHAR_J
    rjmp end

letter_k:
    lpm r24, CHAR_K
    rjmp end

letter_l:
    lpm r24, CHAR_L
    rjmp end

letter_m:
    lpm r24, CHAR_M
    rjmp end

letter_n:
    lpm r24, CHAR_N
    rjmp end

letter_o:
    lpm r24, CHAR_O
    rjmp end

letter_p:
    lpm r24, CHAR_P
    rjmp end

letter_q:
    lpm r24, CHAR_Q
    rjmp end

letter_r:
    lpm r24, CHAR_R
    rjmp end

letter_s:
    lpm r24, CHAR_S
    rjmp end

letter_t:
    lpm r24, CHAR_T
    rjmp end

letter_u:
    lpm r24, CHAR_U
    rjmp end

letter_v:
    lpm r24, CHAR_V
    rjmp end

letter_w:
    lpm r24, CHAR_W
    rjmp end

letter_x:
    lpm r24, CHAR_X
    rjmp end

letter_y:
    lpm r24, CHAR_Y
    rjmp end

letter_z:
    lpm r24, CHAR_Z
    rjmp end

error:
    lpm r24, CHAR_ERROR ; Display the Error pattern to the display
    rjmp end

end:
    ret