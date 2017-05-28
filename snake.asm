.model tiny
locals


.data

    head_x          dw  10
    head_y          dw  20
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

@@game_loop:
    mov     cx, head_x
    mov     dx, head_y
    mov     al, 20
    call    draw_cell
    call    change_head_xy
    call    wait
    jmp     @@game_loop

    ret

main_loop endp


change_head_xy proc near

    mov     ax, head_x
    mov     bx, head_y

    add     ax, 10
    add     bx, 10

    mov     head_x, ax
    mov     head_y, bx

    ret

change_head_xy endp


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
