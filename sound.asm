

step_beep proc near

    mov     ah, 10h
    call    beep

    ret

step_beep endp


beep proc near

    call    turn_on
    call    set_freq
    call    turn_off

    ret

beep endp


set_freq proc near

    push    ax
    push    bx
    push    cx

    mov     bx, ax

    mov     al, 182
    out     43h, al

    mov     ax, bx

    out     42h, al
    mov     al, ah
    out     42h, al

    mov     bx, 25

@@pause1:
    mov     cx, 800

@@pause2:
    dec     cx
    jne     @@pause2
    dec     bx
    jne     @@pause1

    pop     cx
    pop     bx
    pop     ax

    ret

set_freq endp


turn_on proc near

    push    ax
    in      al, 61h
    or      al, 00000011b
    out     61h, al
    pop     ax

    ret

turn_on endp


turn_off proc near

    push    ax
    in      al, 61h
    and     al, 11111100b
    out     61h, al
    pop     ax

    ret

turn_off endp
