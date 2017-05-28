.model tiny
locals


.data

    start_head_x    dw  10
    start_head_y    dw  20

    head_x          dw  ?
    head_y          dw  ?
    head_dx         dw  1
    head_dy         dw  0

    max_len         dw  30
    curr_len        dw  3

    curr_speed      dw  10

    head_color      db  20

    delay           dd  500000
    min_delay       dd  50000
    max_delay       dd  1200000


.code

	org 100h

start:
    jmp     main
    include graphics.asm
    include keyboard.asm

main:
    call    store_mode_n_page
    call    set_mode_n_page

    call    prepare_map
    call    prepare_snake
    call    main_loop

    call    restore_mode_n_page
    call    quit


main_loop proc near

@@game_loop:
    call    wait
    call    handle_keyboard
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


prepare_map proc near

    ret

prepare_map endp


prepare_snake proc near

    mov     cx, start_head_x
    mov     dx, start_head_y

    mov     head_x, cx
    mov     head_y, dx

    mov     al, head_color

    call    draw_cell

    ret

prepare_snake endp


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
