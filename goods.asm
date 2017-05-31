

    food_xs     dw  30, 140, 170, 560, 340, 360, 380
    food_ys     dw  80, 140, 30, 60, 30, 40, 30
    food_found  dw  7 dup(0)

    pois_xs     dw  50, 110, 70
    pois_ys     dw  80, 110, 130
    pois_found  dw  3 dup(0)

    food_color      db  2
    pois_color      db  4


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


