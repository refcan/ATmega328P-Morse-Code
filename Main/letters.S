;;; letters.S 1/12/2017 Daniel Pike
;;; File to declare letter representations for a 7-Segment Display

; including the standard symbol definitions of all ports
#include <avr/io.h>

    ;; The segments of the 7-Segment Display
    SEG_A = 7		; top segment 
	SEG_B = 1 		; upper right segment 
	SEG_C = 2		; lower right segment 
	SEG_D = 3		; buttom segment 
	SEG_E = 4		; lower left segment 
	SEG_F = 5		; upper left segment 
	SEG_G = 6		; middle segment

    ;; Bit mask containing all bits used for the display. Loading it into the display turns off the disdplay since it follows reverse logic.
	ALL_SEGS = _BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G)

    ;; Constants that hold a bit pattern to be displayed that will represent the letter 
	;; (digit rerpesentations inverted since the 7 segment display follows reverse logic)
    CHAR_ERROR = ~(_BV(SEG_G)) ; using dash in the middle as error pattern
	CHAR_A = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_B = ~(_BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_C = ~(_BV(SEG_A) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_D = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_G) )
	CHAR_E = ~(_BV(SEG_A) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_F = ~(_BV(SEG_A) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_G = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_H = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_I = ~(_BV(SEG_E) | _BV(SEG_F) )
	CHAR_J = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) )
	CHAR_K = ~(_BV(SEG_B) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_L = ~(_BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_M = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_E) )
	CHAR_N = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_O = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_P = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_Q = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_R = ~(_BV(SEG_A) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_S = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_T = ~(_BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_U = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) )
	CHAR_V = ~(_BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) )
	CHAR_W = ~(_BV(SEG_B) | _BV(SEG_D) | _BV(SEG_F) )
	CHAR_X = ~(_BV(SEG_C) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_Y = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_F) | _BV(SEG_G) )
	CHAR_Z = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_G) )