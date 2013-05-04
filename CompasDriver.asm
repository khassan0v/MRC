.include "tn2313def.inc"         ; Using ATTiny2313

; ==========================================================
; Defines

.def tmp              = r16      ; variable
.def SWITCHER_STATUS  = r17      ;
.def data             = r18      ; I2c Data reg
.def cnt              = r19      ; I2c counter reg
.def OUT_X_H_M        = r20
.def OUT_X_L_M        = r21

.equ SWI_DDR          = DDRB     ; PortB is switcher and I2c port
.equ SWI_PORT         = PORTB
.equ SWI_IN           = PINB
.equ O_BUS_DDR        = DDRD     ; PortD is LED and O-Bus port
.equ O_BUS_PORT       = PORTD
.equ LED_DDR          = DDRD
.equ LED_PORT         = PORTD
.equ LED_POG          = PD5
.equ POG              = PD0
.equ POS              = PD1

.eseg                            ; EEPROM Data segment

.dseg                            ; SRAM Data segment
.org SRAM_START

; ==========================================================
; SRAM Data segment START

X_M_H: .byte 2
X_M_L: .byte 2

; SRAM Data segment END
; ==========================================================

.cseg                            ; Code segment

.org 0

; ==========================================================
; Interrupts

rjmp RESET ; Reset Handler
reti ;rjmp INT0 ; External Interrupt0 Handler
reti ;rjmp INT1 ; External Interrupt1 Handler
reti ;rjmp TIM1_CAPT ; Timer1 Capture Handler
reti ;rjmp TIM1_COMPA ; Timer1 CompareA Handler
reti ;rjmp TIM1_OVF ; Timer1 Overflow Handler
rjmp TIM0_OVF ; Timer0 Overflow Handler
reti ;rjmp USART0_RXC ; USART0 RX Complete Handler
reti ;rjmp USART0_DRE ; USART0,UDR Empty Handler
reti ;rjmp USART0_TXC ; USART0 TX Complete Handler
reti ;rjmp ANA_COMP ; Analog Comparator Handler
reti ;rjmp PCINT ; Pin Change Interrupt
reti ;rjmp TIMER1_COMPB ; Timer1 Compare B Handler
reti ;rjmp TIMER0_COMPA ; Timer0 Compare A Handler
reti ;rjmp TIMER0_COMPB ; Timer0 Compare B Handler
reti ;rjmp USI_START ; USI Start Handler
reti ;rjmp USI_OVERFLOW ; USI Overflow Handler
reti ;rjmp EE_READY ; EEPROM Ready Handler
reti ;rjmp WDT_OVERFLOW ; Watchdog Overflow Handler
;===========================================================

.include "../lib/libI2C/libI2C_config.inc"
.include "../lib/libI2C/libI2C_Master.inc"
.include "../lib/libLSM303DLH/libLSM303DLH_config.inc"

RESET:                        ; Main programm

	ldi tmp, low(RAMEND)      ; Stack init
	out SPL, tmp

	rcall Init
	sei
	
	GCykle:                   ; Wating for interrupts       
	rjmp GCykle               ; Goosey kicking!

Init:                         ; System unints initialization

	rcall Timer0_Init
	rcall LSM303DLH_config
	rcall LED_Init

	sbi O_BUS_DDR, POG
	sbi O_BUS_DDR, POS
	clr OUT_X_H_M
	clr OUT_X_L_M
	ret

Timer0_Init:                  ; 8-bit Timer0 initialization
	
	ldi tmp, (1<<TOIE0)	
	out TIMSK, tmp
	ldi tmp, (1<<CS00)|(1<<CS02)
	out TCCR0B, tmp
	ret

LED_Init:	

	sbi LED_DDR, LED_POG
	sbi LED_DDR, PD4
	sbi LED_PORT, PD4

	ret

LSM303DLH_read:
	
	; --------------------------------------------------------
	; Operation reading from LSM303DLH
	; Magnetic field sensing OUTX_M register reading

	  OUTX_H_M:                  ; lable for SAK
		rcall I2cStart           ; ST high byte reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTX_H_M            ; SAK

		ldi data, 0x03           ; OUT_X_H_M adress
		rcall I2cWrite           ; SUB
		brcs OUTX_H_M            ; SAK

		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTX_H_M            ; SAK

		rcall I2cRead            ; DATA
		mov OUT_X_H_M, data

		rcall I2cStop            ; SP

	  OUTX_L_M:                  ; lable for SAK
		rcall I2cStart           ; ST low byte reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTX_L_M            ; SAK

		ldi data, 0x04           ; OUT_X_L_M adress
		rcall I2cWrite           ; SUB
		brcs OUTX_L_M            ; SAK

		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTX_L_M            ; SAK

		rcall I2cRead            ; DATA
		mov OUT_X_L_M, data

		rcall I2cStop            ; SP
	; --------------------------------------------------------

	; --------------------------------------------------------
	; Operation reading from LSM303DLH
	; Magnetic field sensing OUTY_M register reading
		
	  OUTY_H_M:                  ; lable for SAK
		rcall I2cStart           ; ST high bute reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTY_H_M            ; SAK

		ldi data, 0x05           ; OUT_Y_H_M adress
		rcall I2cWrite           ; SUB
		brcs OUTY_H_M            ; SAK
		
		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTY_H_M            ; SAK
		
		rcall I2cRead            ; DATA
		mov tmp, data

		rcall I2cStop            ; SP

	  OUTY_L_M:                  ; lable for SAK
		rcall I2cStart           ; ST low byte reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTY_L_M            ; SAK

		ldi data, 0x06           ; OUT_Y_L_M adress
		rcall I2cWrite           ; SUB
		brcs OUTY_L_M            ; SAK

		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTY_L_M            ; SAK
		
		rcall I2cRead            ; DATA
		mov tmp, data

		rcall I2cStop            ; SP
	; --------------------------------------------------------

	; --------------------------------------------------------
	; Operation reading from LSM303DLH
	; Magnetic field sensing OUTZ_M register reading
	  
	  OUTZ_H_M:                  ; lable for SAK
		rcall I2cStart           ; ST high byte reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTZ_H_M            ; SAK

		ldi data, 0x07           ; OUT_Z_H_M adress
		rcall I2cWrite           ; SUB
		brcs OUTZ_H_M            ; SAK
		
		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTZ_H_M            ; SAK
		
		rcall I2cRead            ; DATA
		mov tmp, data

		rcall I2cStop            ; SP

	  OUTZ_L_M:                  ; lable for SAK
		rcall I2cStart           ; ST low byte reading
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs OUTZ_L_M            ; SAK

		ldi data, 0x08           ; OUT_Z_L_M adress
		rcall I2cWrite           ; SUB
		brcs OUTZ_L_M            ; SAK

		rcall I2cStart           ; SR
		
		ldi data, 0x3D           ; LSM303 read adress
		rcall I2cWrite           ; SAD + R
		brcs OUTZ_L_M            ; SAK

		rcall I2cRead            ; DATA
		mov tmp, data

		rcall I2cStop            ; SP
	; --------------------------------------------------------

ret


; =================================================================
; Interrupts Service

TIM0_OVF:                    

	rcall LSM303DLH_read

	cpi OUT_X_H_M, 0b10000000 
	brlo skip_invert
	andi OUT_X_H_M, 0b01111111
	neg OUT_X_H_M
	neg OUT_X_L_M
	skip_invert:

	cbi O_BUS_PORT, POG
	cbi LED_PORT, LED_POG
	
	cpi OUT_X_H_M, 0
	brne TOVF0_exit

	cpi OUT_X_L_M, 80
	brsh TOVF0_exit

	sbi O_BUS_PORT, POG
	sbi LED_PORT, LED_POG
		
TOVF0_exit:
	reti


