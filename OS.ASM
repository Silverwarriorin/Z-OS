org                     0800h                           ;
jp                      begin_os                        ;
ROM_MONITOR_STACK:      equ 0xdbff                      ;
line_counter:           equ 0xdb02                      ;
buffer:                 equ 0xdb08                      ;
byte_count:             equ 0xdb03                      ;
current_value:          equ 0xdb06                      ;
current_location:       equ 0xdb00                      ;
origin_point:           equ 00000h                      ;

write_string:           in a,(3)                        ;
and                     001h                            ;
jp                      z,write_string                  ;
ld                      a,(hl)                          ;
and                     a
ret                     z
out                     (2),a                           ;
inc                     hl                              ;
jp                      write_string                    ;


line_count:             equ 0xdb02                      ;

write_char:             ld b,a                          ;
write_char_loop:        in a,(3)                        ;
and                     001h                            ;
jp                      z,write_char_loop               ;
ld                      a,b                             ;
out                     (2),a                           ;
ret


hex_char_table:         defm "0123456789ABCDEF"         ;


; Input subroutine
get_line:               ld c,000h                       ;
ld                      a,h                             ;
ld                      d,a                             ;
ld                      a,l                             ;
ld                      e,a                             ;


get_next_char:          in a,(3)                        ;
and                     002h                            ;
jp                      z,get_next_char                 ;
in                      a,(2)                           ;
cp                      00dh                            ;
ret                     z
cp                      07fh                            ;
jp                      z,get_line_backspace            ;
call                    write_char                      ;
ld                      (de),a                          ;
inc                     de                              ;
inc                     c
ld                      a,000h                          ;
ld                      (de),a                          ;
jp                      get_next_char                   ;


get_line_backspace:     ld a,c                          ;
cp                      000h                            ;
jp                      z,get_next_char                 ;
dec                     de                              ;
dec                     c
ld                      a,000h                          ;
ld                      (de),a                          ;
ld                      hl,erase_char                   ;
call                    write_string                    ;
jp                      get_next_char                   ;


byte_to_hex_string:     ld b,a                          ;
srl                     a
srl                     a
srl                     a
srl                     a
ld                      d,000h                          ;
ld                      e,a                             ;
push                    hl                              ;
ld                      hl,hex_char_table               ;
add                     hl,de                           ;
ld                      a,(hl)                          ;
pop                     hl                              ;
ld                      (hl),a                          ;
inc                     hl                              ;
ld                      a,b                             ;
and                     00fh                            ;
ld                      e,a                             ;
push                    hl                              ;
ld                      hl,hex_char_table               ;
add                     hl,de                           ;
ld                      a,(hl)                          ;
pop                     hl                              ;
ld                      (hl),a                          ;
inc                     hl                              ;
ld                      a,000h                          ;
ld                      (hl),a                          ;
ret

erase_char:             defm 008h,01bh,"[K",000h        ;
and                     001h                            ;
jp                      z,write_string                  ;
ld                      a,(hl)                          ;
and                     a
ret                     z
out                     (2),a                           ;
inc                     hl                              ;
jp                      write_string                    ;

cls:                    call write_newline              ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;
call                    write_newline                   ;




write_newline:          ld a,00dh                       ;
call                    write_char                      ;
ld                      a,00ah                          ;
call                    write_char                      ;
ret


begin_os:               ld sp,ROM_MONITOR_STACK         ;
call                    cls                             ;
call                    write_newline                   ;
ld                      hl,top_line                     ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,intro_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,intro_line2                  ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,intro_line3                  ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,intro_line4                  ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,bottom_line                  ;
call                    write_string                    ;
call                    write_newline                   ;


begin_ZDOS:             call write_newline              ;
ld                      a,07eh                          ;
call                    write_char                      ;
ld                      hl,buffer                       ;
call                    get_line                        ;
call                    write_newline                   ;
call                    parse                           ;
jp                      (hl)                            ;

; parsing stuff

parse:                  ld bc,parse_table               ;

parse_start:            ld a,(bc)                       ;
ld                      e,a                             ;
inc                     bc                              ;
ld                      a,(bc)                          ;
ld                      d,a                             ;
ld                      a,(de)                          ;
or                      000h                            ;
jp                      z,parser_exit                   ;
ld                      hl,buffer                       ;

match_loop:             cp (hl)                         ;
jp                      nz,no_match                     ;
or                      000h                            ;
jp                      z,parser_exit                   ;
inc                     de                              ;
ld                      a,(de)                          ;
inc                     hl                              ;
jp                      match_loop                      ;

no_match                inc bc                          ;
inc                     bc                              ;
inc                     bc                              ;
jp                      parse_start                     ;


parser_exit:            inc bc                          ;
ld                      a,(bc)                          ;
ld                      l,a                             ;
inc                     bc                              ;
ld                      a,(bc)                          ;
ld                      h,a                             ;
ret



; string and jumps for parsing
parse_table:            
defw                    dump_string,dump_jump           ;
defw                    reboot_string,reboot_jump       ;
defw                    help_string,help_jump,qu_string,help_jump;
defw                    cls_string,cls_jump,clear_string,cls_jump;
defw                    exit_string,exit_jump           ;
defw                    down_string,down_jump           ;
defw                    no_match_string,no_match_jump   ;



; messages

f_msg:                  defm "Respects Paid\n\r",0      ;

address_error_msg:      defm "Invalid address",0        ;
commands:               defm "nhelp,?,dump,reboot,cls,clear,exit",0 ;
top_line:               defm "\033[38;5;14;48;5;14m______________________________________________________________________________\033[38;5;15;48;5;0m",0;
blank_line:             defm "\033[38;5;14;48;5;14m|                                                                            |\033[38;5;15;48;5;0m",0;
bottom_line:            defm "\033[38;5;14;48;5;14m|____________________________________________________________________________|\033[38;5;15;48;5;0m",0;
intro_line:             defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mWelcome to Z-OS 3.2                                                        \033[38;5;14;48;5;14m|",0;
intro_line2:            defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mProgrammed by Gabe W.                                                      \033[38;5;14;48;5;14m|",0;
intro_line3:            defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mROM Version 8                                                              \033[38;5;14;48;5;14m|",0;
intro_line4:            defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mReady.                                                                     \033[38;5;14;48;5;14m|",0;
help_title              defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mWelcome to the command list, here you will find what every command does!   \033[38;5;14;48;5;14m|",0;
help_line_help          defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mHelp and ? are the same command, they both take you here!                  \033[38;5;14;48;5;14m|",0;
help_line_dump          defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mDump will display the contents of a memory address that you specify        \033[38;5;14;48;5;14m|",0;
help_line_reboot        defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mReboot will bring you back to the welcome screen, in case you need info    \033[38;5;14;48;5;14m|",0;
help_line_reboot2       defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mfrom there                                                                 \033[38;5;14;48;5;14m|",0;
help_line_cls           defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mCls and clear both just clear the screen                                   \033[38;5;14;48;5;14m|",0;
help_line_exit          defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mExit will bring you back to the ROM, you need to jump to 0800 to get       \033[38;5;14;48;5;14m|",0;
help_line_exit2         defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mback to Z-OS                                                               \033[38;5;14;48;5;14m|",0;
dump_message:           defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mMemory Dump Utility                                                        \033[38;5;14;48;5;14m|",0;
dump_message2:          defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mDisplays a 256 byte block of memory                                        \033[38;5;14;48;5;14m|",0;
address_entry_msg:      defm "\033[38;5;14;48;5;14m| \033[38;5;13;48;5;14mEnter 4 digit memory address                                               \033[38;5;14;48;5;14m|",0;











downline:               ld a,00Dh                       ;
call                    write_char                      ;
ld                      a,00Ah                          ;
call                    write_char                      ;




no_match_msg:           defm "Illegal Command",0        ;
no_match_string:        defm 0,0                        ;
dump_string:            defm "dump",0                   ;
reboot_string:          defm "reboot",0                 ;
help_string:            defm "help",0                   ;
qu_string               defm "?",0                      ;
cls_string              defm "cls",0                    ;
clear_string            defm "clear",0                  ;
exit_string             defm "exit",0                   ;
down_string             defm "down",0                   ;



; jumps
no_match_jump:          ld hl,no_match_msg              ;
call                    write_string                    ;
ld                      hl,buffer                       ;
call                    write_string                    ;
jp                      begin_ZDOS                      ;





dump_jump:              call cls                        ;
                        ld hl,top_line                  ; Display greeting
                        call write_string               ;
call                    write_newline                   ;
ld                      hl, dump_message                ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl, dump_message2               ;
call                    write_string                    ;
call                    write_newline                   ;
                        ld hl,address_entry_msg         ; get ready to get address
                        call write_string               ;
call                    write_newline                   ;
ld                      hl,bottom_line                  ;
call                    write_string                    ;
call                    write_newline                   ;
                        call address_entry              ; returns with address in HL
                        call write_newline              ;
                        call memory_dump                ;
                        jp begin_ZDOS                   ;



reboot_jump:            jp begin_os                     ;


cls_jump:               call cls                        ;
jp                      begin_ZDOS                      ;


exit_jump:              call cls                        ;
jp                      $0471                           ;



down_jump:              call downline                   ;
jp                      begin_ZDOS                      ;
; Memory dump
; Displays a 256-byte block of memory in 16-byte rows.
; Called with address of start of block in HL
memory_dump:            ld (current_location),hl        ; store address of block to be displayed
                        ld a,000h                       ;
                        ld (byte_count),a               ; initialize byte count
                        ld (line_count),a               ; initialize line count
                        jp dump_new_line                ;
dump_next_byte:         ld hl,(current_location)        ; get byte address from storage,
                        ld a,(hl)                       ; get byte to be converted to string
                        inc hl                          ; increment address and
                        ld (current_location),hl        ; store back
                        ld hl,buffer                    ; location to store string
                        call byte_to_hex_string         ; convert
                        ld hl,buffer                    ; display string
                        call write_string               ;
                        ld a,(byte_count)               ; next byte
                        inc a                           ;
                        jp z,dump_done                  ; stop when 256 bytes displayed
                        ld (byte_count),a               ; not finished yet, store
                        ld a,(line_count)               ; end of line (16 characters)?
                        cp 00fh                         ; yes, start new line
                        jp z,dump_new_line              ;
                        inc a                           ; no, increment line count
                        ld (line_count),a               ;
                        ld a,020h                       ; print space
                        call write_char                 ;
                        jp dump_next_byte               ; continue
dump_new_line:          ld a,000h                       ; reset line count to zero
                        ld (line_count),a               ;
                        call write_newline              ;
                        ld hl,(current_location)        ; location of start of line
                        ld a,h                          ; high byte of address
                        ld hl, buffer                   ;
                        call byte_to_hex_string         ; convert
                        ld hl,buffer                    ;
                        call write_string               ; write high byte
                        ld hl,(current_location)        ;
                        ld a,l                          ; low byte of address
                        ld hl, buffer                   ;
                        call byte_to_hex_string         ; convert
                        ld hl,buffer                    ;
                        call write_string               ; write low byte
                        ld a,020h                       ; space
                        call write_char                 ;
                        jp dump_next_byte               ; now write 16 bytes
dump_done:              ld a,000h                       ;
                        ld hl,buffer                    ;
                        ld (hl),a                       ; clear buffer of last string
                        call write_newline              ;
                        ret                             ;


address_entry:          ld hl,buffer                    ; location for entered string
                        call get_line                   ; returns with address string in buffer
                        ld hl,buffer                    ; location of stored address entry string
                        call hex_to_byte                ; will get high-order byte first
                        jp c, address_entry_error       ; if error, jump
                        ld (current_location+1),a       ; store high-order byte, little-endian
                        ld hl,buffer+2                  ; point to low-order hex char pair
                        call hex_to_byte                ; get low-order byte
                        jp c, address_entry_error       ; jump if error
                        ld (current_location),a         ; store low-order byte in lower memory
                        ld hl,(current_location)        ; put memory address in hl
                        ret                             ;
address_entry_error:    ld hl,address_error_msg         ;
                        call write_string               ;
call                    write_newline                   ;
                        jp address_entry                ;



hex_to_byte:            ld a,(hl)                       ; location of character pair
                        push hl                         ; store hl (hex_char_to_nybble uses it)
                        call hex_char_to_nybble         ;
                        pop hl                          ; returns with nybble value in a reg, or 0ffh if error
                        cp 0ffh                         ; non-hex character?
                        jp z,hex_to_byte_err            ; yes, exit with error
                        sla a                           ; no, move low order nybble to high side
                        sla a                           ;
                        sla a                           ;
                        sla a                           ;
                        ld d,a                          ; store high-nybble
                        inc hl                          ; get next character of the pair
                        ld a,(hl)                       ;
                        push hl                         ; store hl
                        call hex_char_to_nybble         ;
                        pop hl                          ;
                        cp 0ffh                         ; non-hex character?
                        jp z,hex_to_byte_err            ; yes, exit with error
                        or d                            ; no, combine with high-nybble
                        inc hl                          ; point to next memory location after char pair
                        scf                             ;
                        ccf                             ; no-error exit (carry = 0)
                        ret                             ;
hex_to_byte_err:        scf                             ; error, carry flag set
                        ret                             ;



hex_char_to_nybble:     ld hl,hex_char_table            ;
                        ld b,00fh                       ; no. of valid characters in table - 1.
                        ld c,000h                       ; will be nybble value
hex_to_nybble_loop:     cp (hl)                         ; character match here?
                        jp z,hex_to_nybble_ok           ; match found, exit
                        dec b                           ; no match, check if at end of table
                        jp m,hex_to_nybble_err          ; table limit exceded, exit with error
                        inc c                           ; still inside table, continue search
                        inc hl                          ;
                        jp hex_to_nybble_loop           ;
hex_to_nybble_ok:       ld a,c                          ; put nybble value in a
                        ret                             ;
hex_to_nybble_err:      ld a,0ffh                       ; error value
                        ret                             ;



help_jump:              call cls                        ;
                        ld hl,top_line                  ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_title                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,blank_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_help               ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,blank_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_dump               ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,blank_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_reboot             ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_reboot2            ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,blank_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_cls                ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,blank_line                   ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_exit               ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,help_line_exit2              ;
call                    write_string                    ;
call                    write_newline                   ;
ld                      hl,bottom_line                  ;
call                    write_string                    ;
call                    write_newline                   ;

jp                      begin_ZDOS                      ;


































































