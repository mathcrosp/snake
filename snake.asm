.model tiny
locals
.386


.data

    max_len     equ  30
    curr_len    dw  6

    food_count  dw  14
    pois_count  dw  6

    start_head_x    equ  100
    start_head_y    equ  120

    snake_xs    dw  max_len*2 dup(start_head_x)
    snake_ys    dw  max_len*2 dup(start_head_y)

    food_xs     dw  30, 140, 170, 560, 340, 360, 380
    food_ys     dw  80, 140, 30, 60, 30, 40, 30
    food_found  dw  7 dup(0)

    pois_xs     dw  50, 110, 70
    pois_ys     dw  80, 110, 130
    pois_found  dw  3 dup(0)

    head_x      dw  ?
    head_y      dw  ?

    tail_x      dw  ?
    tail_y      dw  ?

    head_dx     dw  1
    head_dy     dw  0

    cell_size       dw  10

    body_color      db  ?
    food_color      db  2
    head_color      db  ?
    pois_color      db  4
    snake_color     db  11
    text_color      db  14
    wall_color      db  4

    delay           dd  400000
    min_delay       dd  49000
    max_delay       dd  1200000

    die_on_cut      db  0

    game_over_msg   db  "GAME OVER", 0dh, 0ah, 24h
    pause_msg       db  "PAUSE", 0dh, 0ah, 24h
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
    call    prepare_goods
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

    mov     cl, snake_color
    sub     cl, 2
    mov     head_color, cl
    sub     cl, 7fh
    mov     body_color, cl

    call    init_snake
    call    draw_snake

    ret

prepare_snake endp


prepare_goods proc near

    call    draw_food
    call    draw_pois

    ret

prepare_goods endp


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
    call    cut_check
    call    food_check
    call    pois_check

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

update_head endp


update_array proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, curr_len

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

    pop     dx
    pop     cx
    pop     bx
    pop     ax

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


cut_check proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, 2

@@checking_loop:
    cmp     bx, [curr_len]
    je      @@exit
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]
    cmp     cx, head_x
    jne     @@continue
    cmp     dx, head_y
    je      @@cut
@@continue:
    add     bx, 2
    jmp     @@checking_loop

@@cut:
    cmp     die_on_cut, 1
    je      @@die
    push    bx
@@cutting_loop:
    cmp     bx, [curr_len]
    je      @@stop_cutting
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]
    call    empty_cell
    add     bx, 2
    jmp     @@cutting_loop
@@stop_cutting:
    pop     bx
    cmp     bx, 2
    je      @@die
    mov     curr_len, bx

@@exit:

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

@@die:
    call    game_over

cut_check endp


food_check proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@checking_loop:
    cmp     bx, [food_count]
    je      @@exit
    mov     cx, food_xs[bx]
    mov     dx, food_ys[bx]
    cmp     cx, head_x
    jne     @@continue
    cmp     dx, head_y
    jne     @@continue
    mov     ax, 0
    cmp     food_found[bx], ax
    je      @@found
@@continue:
    add     bx, 2
    jmp     @@checking_loop

@@found:
    mov     cx, 1
    mov     food_found[bx], cx
    mov     cx, food_xs[bx]
    mov     dx, food_ys[bx]
    call    update_coords
    call    lengthen
    call    draw_snake

@@exit:

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

food_check endp


pois_check proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@checking_loop:
    cmp     bx, [pois_count]
    je      @@exit
    mov     cx, pois_xs[bx]
    mov     dx, pois_ys[bx]
    cmp     cx, head_x
    jne     @@continue
    cmp     dx, head_y
    jne     @@continue
    mov     ax, 0
    cmp     pois_found[bx], ax
    je      @@found
@@continue:
    add     bx, 2
    jmp     @@checking_loop

@@found:
    mov     cx, 1
    mov     pois_found[bx], cx
    mov     cx, pois_xs[bx]
    mov     dx, pois_ys[bx]
    call    shorten
    call    update_tail
    call    empty_tail

@@exit:

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

pois_check endp


lengthen proc near

    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, 0
    mov     snake_xs[bx], cx
    mov     snake_ys[bx], dx

    mov     head_x, cx
    mov     head_y, dx

    call    update_head

    mov     ax, curr_len
    add     ax, 2
    mov     curr_len, ax


    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

lengthen endp


shorten proc near

    push    bx


    mov     bx, curr_len
    sub     bx, 2
    mov     curr_len, bx

    pop     bx

    ret

shorten endp


draw_snake proc near

    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@drawing_loop:
    cmp     bx, [curr_len]
    je      @@exit
    mov     cx, snake_xs[bx]
    mov     dx, snake_ys[bx]
    mov     al, snake_color
    call    draw_body
    add     bx, 2
    jmp     @@drawing_loop

@@exit:
    mov     cx, snake_xs[0]
    mov     dx, snake_ys[0]
    call    draw_head

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


draw_food proc near

    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@drawing_loop:
    cmp     bx, [food_count]
    je      @@exit

    cmp     food_found[bx], 0
    jne     @@drawing_loop

    mov     cx, food_xs[bx]
    mov     dx, food_ys[bx]
    mov     al, food_color
    call    draw_cell
    add     bx, 2
    jmp     @@drawing_loop

@@exit:

    pop     dx
    pop     cx
    pop     bx

    ret

draw_food endp


draw_pois proc near

    push    bx
    push    cx
    push    dx

    mov     bx, 0

@@drawing_loop:
    cmp     bx, [pois_count]
    je      @@exit
    mov     cx, pois_xs[bx]
    mov     dx, pois_ys[bx]
    mov     al, pois_color
    call    draw_cell
    add     bx, 2
    jmp     @@drawing_loop

@@exit:

    pop     dx
    pop     cx
    pop     bx

    ret

draw_pois endp


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


set_die_on_cut proc near

    push    ax

    mov     al, 1
    mov     die_on_cut, al

    pop     ax

    ret

set_die_on_cut endp


change_dir_down proc near

    push    ax

    mov     ax, 1
    add     ax, head_dy
    test    ax, ax
    jnz     @@change_dir
    call    game_over

@@change_dir:
    ; head_dx = 0 && head_dy = 1
    mov     head_dx, 0
    mov     head_dy, 1

    pop     ax

    ret

change_dir_down endp


change_dir_up proc near

    push    ax

    mov     ax, -1
    add     ax, head_dy
    test    ax, ax
    jnz     @@change_dir
    call    game_over

@@change_dir:
    ; head_dx = 0 && head_dy = -1
    mov     head_dx, 0
    mov     head_dy, -1

    pop     ax

    ret

change_dir_up endp


change_dir_right proc near

    push    ax

    mov     ax, 1
    add     ax, head_dx
    test    ax, ax
    jnz     @@change_dir
    call    game_over

@@change_dir:
    ; head_dx = 1 && head_dy = 0
    mov     head_dx, 1
    mov     head_dy, 0

    pop     ax

    ret

change_dir_right endp


change_dir_left proc near

    push    ax

    mov     ax, -1
    add     ax, head_dx
    test    ax, ax
    jnz     @@change_dir
    call    game_over


@@change_dir:
    ; head_dx = -1 && head_dy = 0
    mov     head_dx, -1
    mov     head_dy, 0

    pop     ax

    ret

change_dir_left endp


pause proc near

    mov     dh, 12
    lea     bp, pause_msg
    mov     cx, 5

    mov     ah, 0fh
    int     10h

    sub     ah, cl
    shr     ax, 8
    mov     bl, 2
    div     bl
    mov     dl, al

    mov     bh, curr_page
    mov     bl, text_color
    mov     al, 1
    mov     ah, 13h
    int     10h

    call    pause_beep

    call    wait_for_key

    mov     cx, 280
    mov     dx, 170
@@erase_text:
    cmp     cx, 360
    jge     @@continue
    call    empty_cell
    add     cx, 10
    jmp     @@erase_text

@@continue:
    call    draw_snake
    call    pause_beep

    ret

pause endp


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
    mov     bl, text_color
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
