
vd_init:
    push ax
    push bx

    mov ax, 4F02h
    mov bx, [vd_mode]
    int 10h

    pop bx
    pop ax

    ret

; si - origin of palette data
vd_set_bmp_palette:
    push ax
    push cx
    push dx

    mov dx, 03C8h
    mov al, 0h
    out dx, al
    mov dx, 03C9h
    mov cx, 256
    .loop_p:
        mov al, [si + 2]
        shr al, 2
        out dx, al
        mov al, [si + 1]
        shr al, 2
        out dx, al
        mov al, [si]
        shr al, 2
        out dx, al
        add si, word 4h

        dec cx
        jnz .loop_p

    pop dx
    pop cx
    pop ax
    ret


; set bank to dx 
set_bank:
    push ax
    push bx
    push cx
    
    mov ax, 4f05h
    xor bx, bx
    xor cx, cx
    int 10h

    pop cx
    pop bx
    pop ax

    ret

macro putpixel {
    local .skip
    local .end

    cmp byte [si], 0
    je .skip
    movsb
    jmp .end
    .skip:
    inc si
    inc di
    .end:
}

; draw color data in si of width cx and height dx starting from (ax, bx) position
macro vd_draw_impl pixelfunc {

    local .for_height
    local .overflow
    local .overflow_end
    local .remainder
    local .remainder_end
    local .safe
    local .safe_loop
    local .safe_loop_end
    local .inc_bank
    local .new_line
    local .continue
    local .multiplier_check

    push es
    push si
    push di
    push ax
    push bx
    push cx
    push dx

    push ax
    mov ax, 0A000h
    mov es, ax
    pop ax

    add ax, ax
    add bx, bx

    mov dx, screen_width
    mul dx
    add ax, bx ; position to start drawing from
    
    jnc .inc_bank

    inc dx

    .inc_bank:

    call set_bank

    mov bx, dx ; bx - bank index
    
    pop dx
    push dx

    add cx, cx
    push cx ; width
    mov di, ax
    add cx, ax ; cx - right bound in bank

    mov ax, 2 ; multiplier

    .for_height:
        cmp di, cx
        jbe .safe

        .overflow: ; waiting for bank overflow
            pixelfunc
            dec si
            test di, di
            jz .overflow_end
            pixelfunc
            test di, di
            jnz .overflow
        .overflow_end:

        push dx ; changing bank
        inc bx
        mov dx, bx
        call set_bank
        pop dx

        test cx, cx
        jz .remainder_end
        .remainder: ; filling remaining pixels
            pixelfunc
            dec si
            dec cx
            jz .remainder_end
            pixelfunc
            dec cx
            jnz .remainder
        .remainder_end:
        
        dec bx

        jmp .new_line

        .safe: ; filling entire row
        sub cx, di
        .safe_loop:
            pixelfunc
            dec si
            dec cx
            ; jz .safe_loop_end
            pixelfunc
            dec cx
            jnz .safe_loop

        .safe_loop_end:

        .new_line:
        pop cx
        push cx ; restore width
        
        sub di, cx
        add di, screen_width

        jnc .continue
        ; new line changed bank 
        push dx  
        inc bx
        mov dx, bx
        call set_bank
        pop dx

        .continue:
        dec ax
        jz .multiplier_check
        push cx
        shr cx, 1
        sub si, cx
        pop cx
        add cx, di
        jmp .for_height

        .multiplier_check:
        add cx, di
        dec dx
        mov ax, 2
        jnz .for_height
    

    pop cx ; width

    pop dx
    pop cx
    pop bx
    pop ax
    pop di
    pop si
    pop es

}

vd_draw:
    vd_draw_impl movsb
    ret

vd_draw_alpha:
    vd_draw_impl putpixel
    ret
