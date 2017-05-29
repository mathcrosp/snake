.model tiny
locals


.data

    max_len         equ  30
    curr_len        dw  3

    start_head_x    equ  100
    start_head_y    equ  120
    snake_xs        dw  max_len*2 dup(start_head_x)
    snake_ys        dw  max_len*2 dup(start_head_y)

    head_x          dw  ?
    head_y          dw  ?
    head_dx         dw  1
    head_dy         dw  0

    cell_size       dw  10

    snake_color      db  14

    delay           dd  400000
    min_delay       dd  49000
    max_delay       dd  1200000


.code

	org 100h

start:
    jmp     main
    include graphics.asm
    include keyboard.asm
    include sound.asm

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
    call    handle_keyboard
    call    move_snake
    call    wait
    jmp     @@game_loop

    ret

main_loop endp


move_snake proc near

    call    move_head
    call    step_beep

    ret

move_snake endp


move_head proc near

    ; empty old position
    mov     cx, head_x
    mov     dx, head_y

    call    empty_cell

    ; fill new position
    mov     cx, head_x
    mov     bx, cell_size
    mov     ax, head_dx
    imul    bl
    add     cx, ax
    mov     head_x, cx

    mov     cx, head_y
    mov     bx, cell_size
    mov     ax, head_dy
    imul    bl
    add     cx, ax
    mov     head_y, cx

    mov     cx, head_x
    mov     dx, head_y
    mov     al, snake_color

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

    mov     al, snake_color

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
