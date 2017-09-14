

    food_xs     dw  140, 560, 340, 380, 440, 450, 400, 90, 90, 550
    food_ys     dw  140, 60, 30, 30, 110, 80, 100, 90, 300, 240
    food_found  dw  14 dup(0)

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
    mov     cx, score
    add     cx, 1
    mov     score, cx
    mov     cx, 1
    mov     food_found[bx], cx
    call    food_beep
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
    mov     cx, score
    dec     cx
    mov     score, cx
    mov     cx, 1
    mov     pois_found[bx], cx
    call    pois_beep
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


