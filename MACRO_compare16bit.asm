; ==========================================================
;                    Comparing 16bit numbers
; ==========================================================

; It needs:
; - defenited variable with name "tmp"
; - 2 cell in stack for saving end recovery number in "tmp"
;

.MACRO cp16              ; Start macro definition 

	push tmp

	cp @1,low(@0)	     ; Subtract low byte 
	sbci @2,high(@0)     ; Subtract high byte

	pop tmp
.ENDM    
