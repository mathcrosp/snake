

old_mode        db  ?
old_page        db  ?

curr_mode       db  10h
curr_page       db  0

end_x           dw  ?
end_y           dw  ?


store_mode_n_page proc near

    mov     ah, 0fh
    int     10h
    mov     old_mode, al

    mov     ah, 0fh
    int     10h
    mov     old_page, bh

    ret

store_mode_n_page endp


set_mode_n_page proc near

    mov     ah, 0
    mov     al, curr_mode
    int     10h

    mov     ah, 5
    mov     al, curr_page
    int     10h

    ret

set_mode_n_page endp


restore_mode_n_page proc near

    mov     dl, 0
    mov     ah, 02h
    int     10h

    mov     al, old_mode
    mov     ah, 0
    int     10h

    mov     al, old_page
    mov     ah, 05h
    int     10h

    ret

restore_mode_n_page endp


draw_pixel proc near

    push    ax
    push    bx

    mov     ah, 0ch
    mov     bh, curr_page
    int     10h

    pop     bx
    pop     ax

    ret

draw_pixel endp


draw_cell proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov		bx, [cell_size]
    add		bx, cx
    mov 	[end_x], bx

    mov		bx, [cell_size]
    add		bx, dx
    mov 	[end_y], bx

    push	cx

set_cx:
    pop		cx
    push	cx

cell_fill_loop:
    call	draw_pixel

    inc		cx
    mov		bx, [end_x]
    cmp		cx, bx
    jne		cell_fill_loop

    inc		dx
    mov		bx, [end_y]
    cmp		dx, bx
    jne		set_cx

    pop		cx

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

draw_cell endp


empty_cell proc near

    push    ax

    mov     al, 0
    call    draw_cell

    pop     ax

    ret

empty_cell endp


