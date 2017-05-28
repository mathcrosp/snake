.model tiny
locals


.data

    head_x          dw  10
    head_y          dw  20
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
    call    move_head
    jmp     @@game_loop

    ret

main_loop endp


move_head proc near

    mov     cx, head_x
    mov     dx, head_y

    call    empty_cell

    mov     al, head_color

    ; change head coords
    add     cx, 10
    add     dx, 10

    mov     head_x, cx
    mov     head_y, dx

    call    draw_cell

    ret

move_head endp


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
