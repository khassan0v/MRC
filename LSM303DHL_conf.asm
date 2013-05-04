.equ CRA_REG_M = 0b00010100      ; 30 Hz output rate, Normal OpMode
.equ CRB_REG_M = 0b00100000      ; Max gain
.equ MR_REG_M  = 0b00000000      ; Continuous-conversion mode, Cykle measurments


LSM303DLH_config:                ; Settings for config bits

	; --------------------------------------------------------
	; Operation Writing to LSM303DLH
	; CRA_REG_M (operation mode and output rate) Configuration
	
	  CRA_REG_M_L:               ; lable for SAK
		rcall I2cStart           ; ST
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs CRA_REG_M_L         ; SAK

		ldi data, 0x00           ; CRA_REG_M adress
		rcall I2cWrite           ; SUB
		brcs CRA_REG_M_L         ; SAK
		
		ldi data, CRA_REG_M      ; 
		rcall I2cWrite           ; DATA
		brcs CRA_REG_M_L         ; SAK

		rcall I2cStop            ; SP
	; --------------------------------------------------------

	; --------------------------------------------------------
	; Operation Writing to LSM303DLH
	; CRB_REG_M (gain) Configuration
	   
	  CRB_REG_M_L:               ; lable for SAK
		rcall I2cStart           ; ST
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs CRB_REG_M_L         ; SAK

		ldi data, 0x01           ; CRB_REG_M adress
		rcall I2cWrite           ; SUB
		brcs CRB_REG_M_L         ; SAK
		
		ldi data, CRB_REG_M      ;
		rcall I2cWrite           ; DATA
		brcs CRB_REG_M_L         ; SAK

		rcall I2cStop            ; SP
	; --------------------------------------------------------

	; --------------------------------------------------------
	; Operation Writing to LSM303DLH
	; MR_REG_M (operation mode) Configuration

	  MR_REG_M_L:                ; lable for SAK
		rcall I2cStart           ; ST
	
		ldi data, 0x3C           ; LSM303 write adress
		rcall I2cWrite           ; SAD + W
		brcs MR_REG_M_L          ; SAK

		ldi data, 0x02           ; MR_REG_M adress
		rcall I2cWrite           ; SUB
		brcs MR_REG_M_L          ; SAK

		ldi data, MR_REG_M       ;
		rcall I2cWrite           ; DATA
		brcs MR_REG_M_L          ; SAK

		rcall I2cStop            ; SP
	; --------------------------------------------------------
	ret
