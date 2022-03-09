; Initializes the entry point of the program in memory
; In this case 00000h is used as the ROM is located in he lower 8k of memory
; Next we jump to the COLD_START subroutine which initializes the serial por
; Note: COLD_START must only be called once, for reset call WARM_START

    .org 00000h
    jp COLD_START