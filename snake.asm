.model tiny
locals


.data

    head_x          dw  10
    head_y          dw  20
    head_dx         dw  1
    head_dy         dw  0

    curr_speed      dw  10

    head_color      db  20

    delay           dd  600000


.code

	org 100h

start:
    jmp     main
    include graphics.asm

main:
    call    store_mode_n_page
    call    set_mode_n_page

    call    main_loop

    call    restore_mode_n_page
    call    quit


main_loop proc near

    mov     cx, head_x
    mov     dx, head_y
    mov     al, head_color

    call    draw_cell

@@game_loop:
    call    wait
    call    poll_keyboard
    call    move_head
    jmp     @@game_loop

    ret

main_loop endp


move_head proc near

    ; empty old position
    mov     cx, head_x
    mov     dx, head_y

    call    empty_cell

    ; fill new position
    mov     cx, head_x
    mov     bx, curr_speed
    mov     ax, head_dx
    imul    bl
    add     cx, ax
    mov     head_x, cx

    mov     cx, head_y
    mov     bx, curr_speed
    mov     ax, head_dy
    imul    bl
    add     cx, ax
    mov     head_y, cx

    mov     cx, head_x
    mov     dx, head_y
    mov     al, head_color

    call    draw_cell

    ret

move_head endp


poll_keyboard proc near

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
    jne     @@exit
    mov     head_dx, 1
    mov     head_dy, 0

@@exit:
    ret

poll_keyboard endp


wait proc near

    mov		ax, 8600h
    mov		cx, word ptr delay+2
    mov		dx, word ptr delay
    int		15h

    ret

wait endp


wait_for_key proc near

    mov     ah, 8
    int     21h

    ret

wait_for_key endp


quit proc near

   int      20h

quit endp


end start
