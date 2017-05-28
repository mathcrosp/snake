.model tiny
locals


.data

    head_x          dw  10
    head_y          dw  20


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
    mov     al, 20
    call    draw_cell
    call    wait_for_key

    ret

main_loop endp


wait_for_key proc near

    mov     ah, 8
    int     21h

    ret

wait_for_key endp


quit proc near

   int      20h

quit endp


end start
