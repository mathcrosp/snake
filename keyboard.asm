

handle_keyboard proc near

@@check:
    ; check if no keys
    mov     ah, 01h
    int     16h
    jz      @@exit

    call    key_beep
    xor     ax, ax
    int     16h

@@maybe_j:
    ; j is for down
    cmp     ah, 24h
    jne     @@maybe_k
    call    change_dir_down
    jmp     @@check

@@maybe_k:
    ; k is for up
    cmp     ah, 25h
    jne     @@maybe_h
    call    change_dir_up
    jmp     @@check

@@maybe_h:
    ; h is for left
    cmp     ah, 23h
    jne     @@maybe_l
    call    change_dir_left
    jmp     @@check

@@maybe_l:
    ; l is for right
    cmp     ah, 26h
    jne     @@maybe_p
    call    change_dir_right
    jmp     @@check

@@maybe_p:
    ; p is for pause
    cmp     ah, 19h
    jne     @@maybe_plus
    call    pause
    jmp     @@check

@@maybe_plus:
    cmp     ah, 0dh
    jne     @@maybe_minus
    call    inc_speed
    jmp     @@check

@@maybe_minus:
    cmp     ah, 0ch
    jne     @@maybe_Cc
    call    dec_speed
    jmp     @@check

@@maybe_Cc:
    cmp     ah, 2eh
    jne     @@check
    call    restore_mode_n_page
    call    quit

@@exit:
    ret

handle_keyboard endp


