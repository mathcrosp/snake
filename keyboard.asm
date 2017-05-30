

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
    ; head_dx = 0 && head_dy = 1
    cmp     ah, 24h
    jne     @@maybe_k
    mov     head_dx, 0
    mov     head_dy, 1
    jmp     @@check

@@maybe_k:
    ; k is for up
    ; head_dx = 0 && head_dy = -1
    cmp     ah, 25h
    jne     @@maybe_h
    mov     head_dx, 0
    mov     head_dy, -1
    jmp     @@check

@@maybe_h:
    ; h is for left
    ; head_dx = -1 && head_dy = 0
    cmp     ah, 23h
    jne     @@maybe_l
    mov     head_dx, -1
    mov     head_dy, 0
    jmp     @@check

@@maybe_l:
    ; l is for left
    ; head_dx = 1 && head_dy = 0
    cmp     ah, 26h
    jne     @@maybe_plus
    mov     head_dx, 1
    mov     head_dy, 0
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


