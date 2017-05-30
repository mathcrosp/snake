.model tiny
locals
.386


.data

    max_len     equ  30
    curr_len    dw  8

    start_head_x    equ  100
    start_head_y    equ  120

    snake_xs    dw  max_len*2 dup(start_head_x)
    snake_ys    dw  max_len*2 dup(start_head_y)

    head_x      dw  ?
    head_y      dw  ?

    tail_x      dw  ?
    tail_y      dw  ?

    head_dx     dw  1
    head_dy     dw  0

    cell_size       dw  10

    snake_color     db  14
    wall_color      db  4

    delay       dd  400000
    min_delay       dd  49000
    max_delay       dd  1200000

    game_over_msg   db  "GAME OVER", 0dh, 0ah, 24h
    cli_help_msg    db  "snake.com [/c N] [/h]", 0dh, 0ah, 24h


.code

    org 100h

start:
    jmp     main
    include argparse.asm
    include graphics.asm
    include keyboard.asm
    include sound.asm
    include wall.asm

main:
    call    parse_args
    call    store_mode_n_page
    call    set_mode_n_page

    call    prepare_map
    call    prepare_snake
    call    main_loop

    call    game_over

main_loop proc near

@@game_loop:
    call    handle_keyboard
    call    move_snake
    call    wait
    jmp     @@game_loop

    ret

main_loop endp


init_snake proc near

    mov    head_x, start_head_x
    mov    head_y, start_head_y
    mov    bx, 0

@@fill:
    cmp    bx, curr_len
    je     @@exit
    mov    dx, snake_ys[bx]
    add    dx, [cell_size]
    add    bx, 2
    mov    snake_ys[bx], dx
    jmp    @@fill

@@exit:
    ret

init_snake endp


prepare_map proc near

    call    draw_top_wall
    call    draw_bottom_wall
    call    draw_left_wall
    call    draw_right_wall

    ret

prepare_map endp


prepare_snake proc near

    mov     cx, start_head_x
    mov     dx, start_head_y

    mov     head_x, cx
    mov     head_y, dx

    mov     al, snake_color

    call    init_snake
    call    draw_snake

    ret

prepare_snake endp


move_snake proc near

    call    empty_tail
    call    update_coords
    call    draw_snake
    call    step_beep

    ret

move_snake endp


update_coords proc near

    call    update_head
    call    update_array
    call    update_tail

    ret

update_coords endp


update_head proc near

    push    ax
    push    bx
    push    cx
    push    dx

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
    call    wall_check

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

update_head endp


update_array proc near

    mov    bx, curr_len

@@filling_loop:
    cmp     bx, 0
    je      @@write_head
    sub     bx, 2
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]
    add     bx, 2
    mov     snake_xs[bx], cx
    mov     snake_ys[bx], dx
    sub     bx, 2
    jmp     @@filling_loop

@@write_head:
    mov     cx, head_x
    mov     dx, head_y

    mov     bx, 0
    mov     snake_xs[bx], cx
    mov     snake_ys[bx], dx

    ret

update_array endp


update_tail proc near

    push    bx
    push    cx
    push    dx

    mov     bx, curr_len
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]

    mov     tail_x, cx
    mov     tail_y, dx

    pop     dx
    pop     cx
    pop     bx

    ret

update_tail endp


draw_snake proc near

    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@draw_loop:
    cmp     bx, [curr_len]
    je      @@exit
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]
    push    bx
    mov     al, snake_color
    call    draw_cell
    pop     bx
    add     bx, 2
    jmp     @@draw_loop

@@exit:
    mov     cx, snake_xs[0]
    mov     dx, snake_ys[0]
    mov     al, snake_color
    call    draw_cell

    pop     dx
    pop     cx
    pop     bx

    ret

draw_snake endp


empty_tail proc near

    mov     cx, tail_x
    mov     dx, tail_y
    call    empty_cell

    ret

empty_tail endp


set_snake_color proc near

    lodsb
    lodsb

    mov     snake_color, al

    ret

set_snake_color endp


inc_speed proc near

    mov     dx, word ptr delay+2
    shr     dx, 1
    cmp     dx, word ptr min_delay+2
    jle     @@exit
    mov     word ptr delay+2, dx

@@exit:
    ret

inc_speed endp


dec_speed proc near

    mov     dx, word ptr delay+2
    shl     dx, 1
    cmp     dx, word ptr max_delay+2
    jge     @@exit
    mov     word ptr delay+2, dx

@@exit:
    ret

dec_speed endp


game_over proc near

    mov     dh, 12
    lea     bp, game_over_msg
    mov     cx, 9

    mov     ah, 0fh
    int     10h

    sub     ah, cl
    shr     ax, 8
    mov     bl, 2
    div     bl
    mov     dl, al

    mov     bh, curr_page
    mov     bl, snake_color
    mov     al, 1
    mov     ah, 13h
    int     10h

    call    game_over_beep

    call    wait_for_key

    call    restore_mode_n_page
    call    quit

    ret

game_over endp


wait proc near

    mov     ax, 8600h
    mov     cx, word ptr delay+2
    mov     dx, word ptr delay
    int     15h

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
