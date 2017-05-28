

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
    cmp     al, 6ah
    jne     @@maybe_k
    mov     head_dx, 0
    mov     head_dy, 1

@@maybe_k:
    ; k is for up
    ; head_dx = 0 && head_dy = -1
    cmp     al, 6bh
    jne     @@maybe_h
    mov     head_dx, 0
    mov     head_dy, -1

@@maybe_h:
    ; h is for left
    ; head_dx = -1 && head_dy = 0
    cmp     al, 68h
    jne     @@maybe_l
    mov     head_dx, -1
    mov     head_dy, 0

@@maybe_l:
    ; l is for left
    ; head_dx = 1 && head_dy = 0
    cmp     al, 6ch
    jne     @@maybe_plus
    mov     head_dx, 1
    mov     head_dy, 0

@@maybe_plus:
    cmp     al, 2bh
    je      @@plus_exactly
    cmp     al, 3dh
    jne     @@maybe_minus
@@plus_exactly:
    mov     dx, word ptr delay+2
    shr     dx, 1
    cmp     dx, word ptr min_delay+2
    jle     @@exit
    mov     word ptr delay+2, dx

@@maybe_minus:
    cmp     al, 2dh
    jne     @@exit
    mov     dx, word ptr delay+2
    shl     dx, 1
    cmp     dx, word ptr max_delay+2
    jge     @@exit
    mov     word ptr delay+2, dx

@@exit:
    ret

handle_keyboard endp


