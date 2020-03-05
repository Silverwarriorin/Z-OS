org                     0800h                           ;
jp                      begin_os                        ;
ROM_MONITOR_STACK:      equ 0xdbff


begin_msg:              defm "\r\nZ/DOS\r\n",0           ;


write_string:           in a,(3)


line_count:             equ 0xdb02

;Input subroutine
get_line:               ld c,000h
ld                      a,h
ld                      d,a
ld                      a,l
ld                      e,a


get_next_char:          in a,(3)
and                     002h
jp                      z,get_next_char
in                      a,(2)
cp                      00dh
ret                     z
cp                      07fh
jp                      z,get_line_backspace
call                    write_char
ld                      (de),a
inc                     de
inc                     c
ld                      a,000h
ld                      (de),a
jp                      get_next_char


get_line_backspace:     ld a,c
cp                      000h
jp                      z,get_next_char
dec                     de
dec                     c
ld                      a,000h
ld                      (de),a
ld                      hl,erase_char
call                    write_string
jp                      get_line_next_char




erase_char:             defm 008h,01bh,"[K",000h
and                     001h
jp                      z,write_string
ld                      a,(hl)
and                     a
ret                     z
out                     (2),a
inc                     hl
jp                      write_string

begin_os:               ld sp,ROM_MONITOR_STACK
ld                      hl,begin_msg
call                    write_string;
