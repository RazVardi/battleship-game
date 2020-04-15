;
; BattleShips.asm
;
; Created: 2/29/2020 4:36:55 PM
; Author : Aviv, Raz, Orel
;


; Replace with your application code
.include "8def.inc"
 
.def	ship = r16;define register for submarine 
.def    input_reg = r17
.def    temp_reg  = r18
.def    zero_reg    = r19
.def    one_reg     = r20
.def    row_reg = r21
.def    clm_reg = r22
.def    index_reg = r23
.def    subr_param1_reg = r24
.def    subr_param2_reg = r25

;.equ	battleship=0xb0 ; value of ships
.equ	NUM_OF_POSITIONS  =   1
.equ    NUM_POSITIONS_PER_ROW = 4
.equ    NUM_OF_ROWS = 4
.equ    LEFT_DIGIT_ONLY =  0xF0
.equ    RIGHT_DIGIT_ONLY =  0x0F
.equ    CLEAR_THE_POSITION =4 
.equ    SET_POSITION_TO_X = 1
.equ    SET_POSITION_TO_O = 0
.equ    DISPLAY_CLEAR_CHAR = 0x11
.equ    DISPLAY_X_CHAR = 0x3E
.equ    DISPLAY_O_CHAR = 0x0
.equ    ADVANCE_TO_NEXT_ROW_INCREMENT = 0x10
.equ    MT_SHIP = 0xB0
.equ    SHIP_SIZE = 0x3	;0x3


;data    
.dseg  ;ram memory
;matrixValue
.org 0x90		  ; define adress
topline: .byte NUM_POSITIONS_PER_ROW+1
.org 0xa0
row0:	.byte  NUM_POSITIONS_PER_ROW  ; destination for data
borderLine1: .byte 1
		

.org 0xb0
row1:	.byte  NUM_POSITIONS_PER_ROW  ; destination for data
borderLine2: .byte 1
.org 0xc0
row2:	.byte  NUM_POSITIONS_PER_ROW  ; destination for data
borderLine3: .byte 1
.org 0xd0
row3:.byte  NUM_POSITIONS_PER_ROW  ; destination for data
borderLine4: .byte 1;remodified
.org 0xe0;remodified
bottomline: .byte NUM_POSITIONS_PER_ROW+1
;.org 0x70
;.db  arr1: b0,b0,b0,00

.cseg	;flash memory

;code
start: 
	.org	0x00
	ldi	r16,LOW(RAMEND)		; initialize
	out	SPL,r16			; stack pointer		   Store Register to I/O Location-out for printing
	ldi	r16,HIGH(RAMEND)	; to RAMEND
	out	SPH,r16			; "
	

	ldi zero_reg,0
	ldi one_reg,1	
	ldi temp_reg,  0x44 ; don't erase this!!
	sts borderLine1,temp_reg  ; don't erase this!! store direct to data space
	
	add temp_reg,zero_reg
	sts borderLine2,temp_reg  ; don't erase this!! store direct to data space
	add temp_reg,zero_reg
	sts borderLine3,temp_reg  ; don't erase this!!
	add temp_reg,zero_reg;remodified
	sts borderLine4,temp_reg;remodified
	ldi temp_reg,  0x44     ; don't erase this!!
	ldi xH, HIGH(topline)
	ldi xL, LOW(topline)
	ldi yH, HIGH(bottomline)
	ldi yL, LOW(bottomline)
	ldi index_reg,0
	fillLoop:
		

		st X,temp_reg  ; don't erase this!!
		st Y,temp_reg
		add index_reg,one_reg
		add xL,one_reg
		adc xH,zero_reg	 ;add carry
		add yL,one_reg
		adc yH,zero_reg
		cpi index_reg,NUM_POSITIONS_PER_ROW+1
		brne fillLoop
	
	;initialize index reg
	ldi  index_reg,0

	
main:    
	mov subr_param1_reg, input_reg
	
;	rcall getInputPosition	 ;call function
	
	mov subr_param1_reg, row_reg
	mov subr_param2_reg, clm_reg
	rcall InsShips
	rcall InsInput
	;rcall nine_reds
	add  index_reg, one_reg ; increment cntr
	cpi index_reg, NUM_OF_POSITIONS
    brne main ; do while (index_reg < NUM_POSITIONS) ....

	
end: rjmp end

;
; SUBROUTINE getInputPosition: reads input_reg (2-digit hex number Row in Hi Digit, Column in Lo Digit
;                           and divides it into row number & column number
; Inputs: subr_param1_reg = input position
; Outputs: reg X  contains the address of the position to display
;          subr_param1_reg = row number
;          subr_param2_reg = column number
;


ldi zero_reg,0
ldi one_reg,1
;adress of row1 0x0070 to 0x0074 or 0x0080 to 0x0084 or 0x0090 to 0x0094 or 0x00a0 to 0x00a4 and can't be the same other sub
;adress of row2	0x0070 to 0x0074 or 0x0080 to 0x0084 or 0x0090 to 0x0094 or 0x00a0 to 0x00a4 and can't be the same other sub
;adress of row3	0x0070 to 0x0074 or 0x0080 to 0x0084 or 0x0090 to 0x0094 or 0x00a0 to 0x00a4 and can't be the same other sub



InsShips:     	 ;INSERT SHIPS
	push xL
	push xH
	push zL
	push zH
	push index_reg
	push temp_reg
	push ship
	

	;read  ship location
	ldi zL, low(ShipsLocation*2)
	ldi zH, high(ShipsLocation*2)
	ldi xH, 0x00
	ldi temp_reg, 0xB0; empty ship
	ship_loop1: ; first loop
		lpm xL, z+ ; The start point of the ships accoroding to the input
		cpi xL, 0x00 ; if its the end of the array(ShipsLocation)
		breq end_ship ; then end function
		
		push input_reg ; passes the value to check
		push index_reg
		mov input_reg, xL ; function argument
		rcall checkShips ;  checks if the input is valid 
		mov ship, index_reg ; insert result in ship
		pop index_reg ; return from function
		pop input_reg
	
		cpi ship, 0x00 ; if the ships input is unvalid
		breq end ; then end program
		
		ldi index_reg, 0x03
		ship_loop2: ; second loop
			st x+, temp_reg
			dec index_reg
			brne ship_loop2 
		rjmp ship_loop1
	end_ship: nop

	
	pop ship
	pop temp_reg
	pop index_reg
	pop zH
	pop zL
	pop xH
	pop xL
ret


InsInput:     	 ;INSERT GAME INPUT
	push xL
	push xH
	push zL
	push zH
	push clm_reg
	push temp_reg
	push one_reg
	
	; read from GameInput
	ldi zL, LOW(GameInput*2)
	ldi zH, HIGH(GameInput*2)

	ldi xH, 0x00
	
	input_loop: ; first loop
		; rcall nine_reds
		lpm xL, z+ ; getting the cell indicated in the input
		cpi xL, 0xEE ; if the input is 0xEE then the game is over
		breq input_end
		// "checkInput" pops
		pop input_reg
		pop index_reg
		//
		mov input_reg, xL // passes argument to "checkInput"
		rcall checkInput // checks if input is valid
		mov clm_reg, index_reg // get the return argument from the function
		// checkInput pushes
		push index_reg
		push input_reg
		//
		cpi clm_reg, 0x00
		breq input_loop
		ld temp_reg, x
		cpi temp_reg, 0x00
		breq br_miss
		cpi temp_reg, 0xb0
		breq br_hit
		rjmp input_loop

		; branches
		br_miss:
			ldi temp_reg, 0x11
			st x, temp_reg
			rjmp input_loop
		br_hit:
			 ldi temp_reg, 0xb8
			 st x, temp_reg
			 rjmp input_loop
		
		input_end:

	pop one_reg
	pop temp_reg
	pop clm_reg
	pop zH
	pop zL
	pop xH
	pop xL

ret

; the function gets "input_reg" as argument
checkShips:     	
	push temp_reg
	push one_reg ; mask
	
	; check if the input is bigger or equal then 0xa0 and lower or equal then 0xd1
	ldi one_reg, 0x01 
	ldi temp_reg, 0xf0
	and temp_reg, input_reg
	lsr temp_reg
	lsr temp_reg
	lsr temp_reg
	lsr temp_reg ; divide the num by 16
	cpi temp_reg, 0x01
	brge br_bt 
	rjmp br_ship_false
	br_bt: ; bigger than
		cpi temp_reg, 0x0e 
		brlt br_lt
		rjmp br_ship_false
	br_lt:	
		and input_reg, one_reg ; isolating the first digit
		cpi input_reg, 0x00 ; is equal 0
		breq br_ship_true	; or
		cpi input_reg, 0x01 ; is equal 1
		breq br_ship_true ; then true
		rjmp br_ship_false ; else false
	
	br_ship_false:
		ldi index_reg, 0x00
		rjmp endShipCheck
	br_ship_true:
		ldi index_reg, 0x01

	endShipCheck: 

	pop one_reg
	pop temp_reg
ret ; return index_reg

; the function gets "input_reg" as argument
checkInput:     	
	push temp_reg
	
	
	; check if the input is bigger or equal then 0xa0 and lower or equal then 0xd1
	ldi temp_reg, 0xf0
	and temp_reg, input_reg
	lsr temp_reg
	lsr temp_reg
	lsr temp_reg
	lsr temp_reg ; divide the num by 16
	cpi temp_reg, 0x01
	brge br_bt_inp
	rjmp br_input_false
	br_bt_inp: ; bigger than
		cpi temp_reg, 0x0E 
		brlt br_lt_inp
		rjmp br_input_false
	br_lt_inp: ; less than	
		ldi temp_reg, 0x0f
		and input_reg, temp_reg ; isolating the first digit(hex)
		cpi input_reg, 0x0E
		brlt br_input_true
		rjmp br_input_false ; else false
	
	br_input_false:
		ldi index_reg, 0x00
		rjmp endInputCheck
	br_input_true:
		ldi index_reg, 0x01

	endInputCheck: 

	pop temp_reg
ret ; return index_reg

;getInputPosition:  ;GameInput.
;push y,

		  ;load imedately value to register r16=ship
;ldi r28,0x00a0	  ;load imedately adress to register r26
;refill1:
		;st Y,ship
		;st x,ship
		;add ship,one_reg
		;add xL,one_reg
		;adc xH,zero_reg
		;add yL,one_reg
		;adc yH,zero_reg
		
		;movw x,r16
;		ldi r27,0x00a0	   ;check valid adress
;		cp r28,r27
;		brge secondcondition
;		rjmp refill1
;secondcondition:
;				ldi r27,0x00a5
;				cp r28,r27
;				brlt continue
;				rjmp refill1
		
;continue:
;ldi ship,3
;ldi r28,0x00A0
;newrefill1:
;		ldi r26,0x00b0		 ;load imedately value 0x00b0 in regirster r28
;		st  y,r26			;stored in ram memory value of register r28 by x regirster
;		inc r28			  ;increment register iput for bo value
;		cpi ship,3		   ; compare condition
;		dec ship		   ;decrement
;		breq arrayline2	  ;condion adress with 0
;		rjmp newrefill1	  ;do loop
;arrayline2:	
;ldi ship,3  ;init ship with 3
;ldi r28,0x00b0
;refill2: ;start loop
;		ldi r27,0x00b0	   ;check valid adress
;		cp r28,r27
;		brge secondcondition2
;		rjmp refill2
;secondcondition2:
;				ldi r27,0x00b5
;				cp r26,r27
;				brlt continue2
;continue2:
;ldi ship,3
;ldi r28,0x00b0
;newrefill2:
;		ldi r26,0x00b0
;		st y,r26
;		inc r28
;		cpi ship,3
;		dec ship
;		breq arrayline3
;		rjmp newrefill2
;arrayline3:
;ldi ship,3
;ldi r28,0x00c0	
;refill3:
;		ldi r27,0x00c0
;		cp r28,r27
;		brge secondcondition3
;		rjmp refill3
;secondcondition3:
;				ldi r27,0x00c5
;				cp r26,r27
;				brlt continue3
;continue3:
;ldi ship,3
;ldi r28,0x00c0
;newrefill3:
;		ldi r26,0x00b0
;		st y,r26
;		inc r28
;		cpi ship,3
;		dec ship
;		breq endfunction
;		rjmp newrefill3
;endfunction:
;				ret
	   

;
; SUBROUTINE calcAddr - calculates the address of the position for input
;                       column and row values
;
; Inputs: subr_param1_reg = row number
;         subr_param2_reg = column number
; Outputs: reg X  contains the address of the position to display
;
;calcAddr:
;	ret




;nine_reds:
;	ldi r16, 0 // this is the 'cnt'
;	ldi r17, 0 // for arrayline1
;	ldi r18, 0 // for arrayline2
;	ldi r19, 0 // for arrayline3
;	ldi r20, 0 // for arrayline4
;	loop_start1:
;		cpi r21, 4
;		ldi r17, 0x00B8
;		st y, r17
;		inc r16
;		dec r21
;		breq loop_end1
;		rjmp loop_start1
;	loop_end1:

;	loop_start2:
;		cpi r22, 4
;		ldi r18, 0x00B8
;		st y, r18
;		inc r16
;		dec r22
;		breq loop_end2
;		rjmp loop_start2
;	loop_end2:

;	loop_start3:
;		cpi r23, 4
;		ldi r19, 0x00B8
;		st y, r19
;		inc r16
;		dec r23
;		breq loop_end3
;		rjmp loop_start3
;	loop_end3:

;	loop_start4:
;		cpi r24, 4
;		ldi r20, 0x00B8
;		st y, r20
;		inc r16
;		dec r24
;		breq loop_end4
;		rjmp loop_start4
;	loop_end4:
 
 
GameInput: .db 0xe, 0xb1, 0xd0, 0xc2, 0xa2,0xc3, 0xEE, 0x00 ;array fire ships
ShipsLocation: .db  0xd0,0xb0,0xa1, 0x00