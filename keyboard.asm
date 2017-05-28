

handle_keyboard proc near

    ; check if no keys
    mov     ah, 01h
    int     16h
    jz      @@exit

    xor     ax, ax
    int     16h

@@maybe_j:
    ; j is for down
    ; head_dx = 0 && head_dy = 1
    cmp     ah, 24h
    jne     @@maybe_k
    mov     head_dx, 0
    mov     head_dy, 1

@@maybe_k:
    ; k is for up
    ; head_dx = 0 && head_dy = -1
    cmp     ah, 25h
    jne     @@maybe_h
    mov     head_dx, 0
    mov     head_dy, -1

@@maybe_h:
    ; h is for left
    ; head_dx = -1 && head_dy = 0
    cmp     ah, 23h
    jne     @@maybe_l
    mov     head_dx, -1
    mov     head_dy, 0

@@maybe_l:
    ; l is for left
    ; head_dx = 1 && head_dy = 0
    cmp     ah, 26h
    jne     @@maybe_plus
    mov     head_dx, 1
    mov     head_dy, 0

@@maybe_plus:
    cmp     ah, 0dh
    jne     @@maybe_minus
    mov     dx, word ptr delay+2
    shr     dx, 1
    cmp     dx, word ptr min_delay+2
    jle     @@exit
    mov     word ptr delay+2, dx

@@maybe_minus:
    cmp     ah, 0ch
    jne     @@maybe_Cc
    mov     dx, word ptr delay+2
    shl     dx, 1
    cmp     dx, word ptr max_delay+2
    jge     @@exit
    mov     word ptr delay+2, dx

@@maybe_Cc:
    cmp     ah, 2eh
    jne     @@exit
    call    restore_mode_n_page
    call    quit

@@exit:
    ret

handle_keyboard endp


