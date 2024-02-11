;**********************************************************
; This program control a bottle labeling and packing machine.
; Photocell sensor is connected into RB0
; 7-Segments is connected to PORTB (We connect RB1 to a, RB2 to b ???.And RB7 to g)
; Digits selection of bottles number 7-Segments is connected to RA0
; Digits selection of cartoon number 7-Segments is connected to RA1
; Conveyor belt motor is connected to RA2 (Connect to LED1 on board)
; Label actuator is connected to RA3(Connect to LED2 on board)
; START pushbutton is connected to RA4
; The program uses a PIC16F84A running at crystal oscillator of frequency 4MHz. 
;**********************************************************
 include "p16f84A.inc"
;**********************************************************
DCounter1 EQU 0X0C
DCounter2 EQU 0X0D
DCounter3 EQU 0X0E
DCounter4 EQU 0X0F
DCounter10 EQU 0X20
DCounter20 EQU 0X21
DCounter30 EQU 0X22
DCounter40 EQU 0X23
HEATER     EQU 0X24
COUNTER_HEATER EQU 0X25
DCounter100 EQU 0X26
DCounter200 EQU 0X27
DCounter300 EQU 0X28
DCounter400 EQU 0X29
DCounter1000 EQU 0X30
DCounter2000 EQU 0X31
DCounter3000 EQU 0X32
DCounter4000 EQU 0X33
DCounter11 EQU 0X34
DCounter22 EQU 0X35
DCounter33 EQU 0X36
DCounter44 EQU 0X37
; Macro definitions

push	macro

	movwf		WTemp		; WTemp must be reserved in all banks
	swapf		STATUS,W		; store in W without affecting status bits
	banksel	StatusTemp		; select StatusTemp bank
	movwf		StatusTemp		; save STATUS
	endm

pop	macro

	banksel	StatusTemp		; point to StatusTemp bank
	swapf		StatusTemp,W		; unswap STATUS nibbles into W	
	movwf		STATUS		; restore STATUS
	swapf		WTemp,F		; unswap W nibbles
	swapf		WTemp,W		; restore W without affecting STATUS
	endm
;**********************************************************
; User-defined variables
	cblock		0x0C		; bank 0 assignments
	WTemp	
	StatusTemp
	;????			Add all variables here.	
	endc
;**********************************************************
; Start of executable code
	org	0x00		;Reset vector
	nop
	goto    	Main		
	org	0x04	        	;
	goto		INT_SVC
	;;;;;;; Main program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main
	call	Initial		;Initialize everything
MainLoop
	call	Bottle_Number			;Check if the number of bottles reaches to nine
	call    	Caroon_Number		;Check if the number of packing bottles reaches to nine.
	goto	MainLoop			;Do it again
;;;;;;;	Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine performs all initializations of variables and registers.
Initial	
banksel TRISA
BSF TRISA,RA0 ; SET RA0 AS INPUT
BCF TRISA,RA1 ;SET RA1 AS OUTPUT
BSF TRISA,RA2 ;SET RA2 AS INPUT
BCF TRISA,RA3 ;SET RA3 AS OUTPUT_PUMPA
BCF TRISA,RA4 ;SER RA4 AS OUTPUT
BCF TRISA,RA5 ;SET RA5 AS OUTPUT_HEATER
BCF TRISA,RA6 ;SET RA6 AS OUTPUT_MIXER
BSF TRISB,RB0 ;SET RB0 AS INPUT 
BSF TRISB,RB1 ;SET RB1 AS INPUT 
MOVLW D'21'
MOVWF HEATER
	Return
;;;;;;; Bottle_Number subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine Test if the number of bottles reaches to nine. 
START_MACHINE 
BTFSS,RA0
GOTO FINISH
GOTO LEDRUN
	Return
;**********************************************************
;;;;;;; Caroon_Number subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine Test if the number of packing bottles reaches to nine.
LEDRUN
BANKSEL PORTA
BCF PORTA,RA1
CALL SELECTION
	Return
;**********************************************************
SELECTION
BANKSEL PORTA
BTFSC PORTA,RA2
GOTO STATUSA
GOTO OUTHERWISE

RETURN
;**********************************************************
STATUS_A
BCF PORTA,RA3 ; SET AS HIGHT PUMP1
CALL DELAY_FLUIDA_1
BCF PORTA,RA4 ;SET AS HIGHT PUMP2
CALL DELLY_FLUID_2
MOVLW D'13'
MOVWF COUNTER_HEATER
BCF PORTA,RA5 ;SET HIGHT HEATER
BCF PORTA,RA6 ;SET HIGHT MIXER
CALL DELAY_HAETER
LOOP_HEATER
MOVLW D'3'
ADDWF HEATER
DECFSZ COUNTER_HEATER
GOTO LOOP_HEATER
GOTO FINIH
RETURN
;**********************************************************
OTHERWISE 
BTFSC PORTB,RB0
GOTO STATUSB
GOTO STATUSC
;**********************************************************
STATUSB
BCF PORTA,RA3 ;SET HIGHT PUMPA
CALL DELAY_STATUSB_FLUIDA
MOVLW D'8'
MOVWF COUNTER_HEATER
BCF PORTA,RA5 ;SET HIGHT HEATER
BCF PORTA,RA6 ;SET HIGHT MIXER
CALL DELAY_HAETER
LOOP_HEATER1
MOVLW D'3'
ADDWF HEATER
DECFSZ COUNTER_HEATER
GOTO LOOP_HEATER1
GOTO FINIH
RETURN
;**********************************************************
STATUSC
BCF PORTA,RA3 ;SET HIGHT PUMPA
CALL DELLY_FLUID_2 ; 120 SECOUND
BCF PORTA,RA4 ;SET AS HIGHT PUMP2
CALL DELAY_80S
;****************INCREASE TO 45C
MOVLW D'8' 
MOVWF COUNTER_HEATER
BCF PORTA,RA5 ;SET HIGHT HEATER
BCF PORTA,RA6 ;SET HIGHT MIXER
CALL DELAY_HAETER
LOOP_HEATER1
MOVLW D'3'
ADDWF HEATER
DECFSZ COUNTER_HEATER
GOTO LOOP_HEATER1
GOTO FINIH
RETURN

;;;;;;; Delay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine to get a delay with 80 Sec.
DELAY_80S
MOVLW 0X99
MOVWF DCounter11
MOVLW 0X9a
MOVWF DCounter22
MOVLW 0Xf7
MOVWF DCounter33
MOVLW 0X04
MOVWF DCounter44
LOOP
DECFSZ DCounter11, 1
GOTO LOOP
DECFSZ DCounter22, 1
GOTO LOOP
DECFSZ DCounter33, 1
GOTO LOOP
DECFSZ DCounter44, 1
GOTO LOOP
RETURN
;;;;;;; Delay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine to get a delay with 180 Sec.
DELAY_STATUSB_FLUIDA
MOVLW 0X9d
MOVWF DCounter1000
MOVLW 0Xda
MOVWF DCounter2000
MOVLW 0Xeb
MOVWF DCounter3000
MOVLW 0X09
MOVWF DCounter4000
LOOP
DECFSZ DCounter1000, 1
GOTO LOOP
DECFSZ DCounter2000, 1
GOTO LOOP
DECFSZ DCounter3000, 1
GOTO LOOP
DECFSZ DCounter4000, 1
GOTO LOOP
NOP
NOP
RETURN
;;;;;;; Delay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine to get a delay with 45 Sec.
DELAY_HAETER
MOVLW 0X63
MOVWF DCounter100
MOVLW 0Xb7
MOVWF DCounter200
MOVLW 0X3b
MOVWF DCounter300
MOVLW 0X03
MOVWF DCounter400
LOOP3
DECFSZ DCounter100, 1
GOTO LOOP3
DECFSZ DCounter200, 1
GOTO LOOP3
DECFSZ DCounter300, 1
GOTO LOOP3
DECFSZ DCounter400, 1
GOTO LOOP3
NOP
NOP
RETURN

;;;;;;; Delay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine to get a delay with 90 Sec.
DELAY_FLUIDA_1
MOVLW 0Xcc
MOVWF DCounter1
MOVLW 0X6d
MOVWF DCounter2
MOVLW 0X76
MOVWF DCounter3
MOVLW 0X05
MOVWF DCounter4
LOOP
DECFSZ DCounter1, 1
GOTO LOOP
DECFSZ DCounter2, 1
GOTO LOOP
DECFSZ DCounter3, 1
GOTO LOOP
DECFSZ DCounter4, 1
GOTO LOOP
NOP
	Return
;;;;;;; Delay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine to get a delay with 120 Sec.
DELLY_FLUID_2
MOVLW 0X67
MOVWF DCounter10
MOVLW 0Xe7
MOVWF DCounter20
MOVLW 0Xf2
MOVWF DCounter30
MOVLW 0X06
MOVWF DCounter40
LOOP2
DECFSZ DCounter10, 1
GOTO LOOP2
DECFSZ DCounter20, 1
GOTO LOOP2
DECFSZ DCounter30, 1
GOTO LOOP2
DECFSZ DCounter40, 1
GOTO LOOP2
NOP
NOP
RETURN
; ;;;;;;;  Bottle_Labeling subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine start labeling and counts the number of labeled bottles

Bottle_Labeling
	bcf	    INTCON, INTF	;Clear the External interrupt flag
;	write the code here
	goto		POLL    	;Check for another interrupt
;**********************************************************
INT_SVC
push
POLL
	btfsc		INTCON, INTF	; Check for an External Interrupt
	goto		Bottle_Labeling
;	btfsc	...		        		; Check for another interrupt
;	call	...
;	btfsc	...		        		; Check for another interrupt
;	call	...
	pop
	retfie

;**********************************************************
FINISH
NOP
	End