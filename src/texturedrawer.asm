macro load_anim texture, len {
    mov [texture#.seg], es
    mov [texture#.addr], di

    push ecx

    mov ecx, 0

    local anim_load

    anim_load:
    push ds
    push si
    push eax

    push ebx
    push edx

    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov ax, [texture + 4 * ecx + 2]
    mov bx, [texture_bitmap.width]
    mul ebx
    xor edx, edx
    mov dx, [texture + 4 * ecx]
    add eax, edx

    pop edx
    pop ebx
    
    push bx
    push cx

    mov bx, [texture#.width]
    mov cx, [texture#.height]

    call align_si_segment

    push edx
    mov edx, eax
    shr edx, 4
    and eax, 0Fh
    add si, ax
    mov ax, ds
    add ax, dx
    mov ds, ax
    pop edx

    call load_texture

    pop cx
    pop bx

    inc cx
    cmp cx, len

    pop eax
    pop si
    pop ds
    jne anim_load

    pop ecx
}

macro load texture {
    load_anim texture, 1
}

macro draw_anim_impl w, h, texture, index, drawfunc {
    push ds
    push si
    push cx
    push dx
    push ax

    mov ax, storage
    mov ds, ax

    push bx

    push dx

    xor dx, dx
    mov ax, w
    mov bx, h
    mul bx

    pop dx

    mov bx, index
    mul bx

    pop bx

    mov cx, w
    mov dx, h

    mov si, [texture#.addr]
    mov ds, [texture#.seg]

    add si, ax

    pop ax
    
    call align_si_segment

    call drawfunc

    pop dx
    pop cx
    pop si
    pop ds
}

macro draw_anim texture, index {
    draw_anim_impl [texture#.width], [texture#.height], texture, index, vd_draw
}

macro draw_anim_alpha texture, index {
    draw_anim_impl [texture#.width], [texture#.height], texture, index, vd_draw_alpha
}

macro draw texture {
    draw_anim texture, 0
}

macro clear_rect w, h {
    draw_anim_impl w, h, void, 0, vd_draw
}

macro clear texture {
    clear_rect [texture#.width], [texture#.height]
}

; dir: 0 - up, 1 - right, 2 - down, 3 - left
macro clear_dir texture, dir, len {
    push cx
    push dx
    
    local .c1
    local .c2
    local .c3
    local .end
    
    cmp dir, 0
    jne .c1
    
    push ax
    add ax, [texture#.height]
    sub ax, len

    clear_rect [texture#.width], len
    pop ax

    .c1:
    cmp dir, 1
    jne .c2

    clear_rect len, [texture#.height]    

    .c2:
    cmp dir, 2
    jne .c3

    clear_rect [texture#.width], len    

    .c3:

    cmp dir, 3
    jne .end

    push bx
    add bx, [texture#.width]
    sub bx, len

    clear_rect len, [texture#.height]
    pop bx


    .end:

    pop dx
    pop cx

}

macro clear_entity {    
    inc ax
    inc bx

    clear_rect 14, 14

    dec ax
    dec bx
}

; ds:si - start of the source bitmap
; es:di - destination in memory
; bx - width
; cx - height
load_texture:
    push ds
    push si
    push ax
    push bx
    push cx
    push dx

    call align_di_segment
    
    mov dx, 320

    push dx
    mov ax, bx
    mul cx
    pop dx

    add di, ax

    .read_loop:
        call align_si_segment

        sub di, bx

        push cx
        mov cx, bx

        rep movsb

        pop cx

        sub di, bx

        add si, dx
        sub si, bx

        loop .read_loop
    
    add di, ax

    call align_di_segment

    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    pop ds

    ret
