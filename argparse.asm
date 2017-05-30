

parse_args proc near

    xor     dx, dx
    mov     si, 80h
    lodsb

@@arg_processing:
    lodsb

    cmp     al, 9h
    je      @@skip_space
    cmp     al, 20h
    je      @@skip_space

    cmp     al, 2dh
    je      @@key_found
    cmp     al, 2fh
    je      @@key_found

    ret

@@skip_space:
    loop    @@arg_processing

@@key_found:
    lodsb

    cmp     al, 43h ; C: snake color
    jne     @@next_1
    call    set_snake_color

@@next_1:
    cmp     al, 63h ; c: snake color
    jne     @@next_2
    call    set_snake_color

@@next_2:
    cmp     al, 48h ; H: help
    jne     @@next_3
    call    show_help_and_quit

@@next_3:
    cmp     al, 68h ; h: help
    jne     @@next_l
    call    show_help_and_quit

@@next_l:
    loop    @@arg_processing

    ret

parse_args endp


show_help_and_quit proc near

    mov     ah, 9
    lea     dx, cli_help_msg
    int     21h
    int     20h

show_help_and_quit endp


