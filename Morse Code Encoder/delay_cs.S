;;; NOT written by me, provided as part of the coursework
	.section .text
	.global delay_cs
delay_cs:

	push r0
	push r17
	push r24
	
	clr r0
2:	ldi r17, 156
	
1:	dec r0			; 1 tick
	nop			; 1 tick
	brne 1b			; 2 ticks

	dec r17			; 1 tick + 255*4 + 3 = 256*4 ticks = 1024 ticks
	brne 1b			

	dec r24			; 1024*156 = 159744 ticks approx 10ms
	brne 2b			; and now jump back for the number of
				; ms in r24.
	pop r24
	pop r17
	pop r0
	ret
