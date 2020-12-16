macro to_tile x, y {
    mov ax, x
    mov bx, y
    shl ax, 3
    shl bx, 3
    add ax, 6
    add bx, 88
}

macro from_coords {
    add ax, 3
    sub bx, 80
    shr ax, 3
    shr bx, 3
}

macro wait_t {
    push ecx
    local .wait_loop
    local .inner_wait_loop
    mov ecx, 3
    .wait_loop:
    push ecx
    mov ecx, 10000000
    .inner_wait_loop:
    loop .inner_wait_loop
    pop ecx
    loop .wait_loop
    pop ecx
}

macro clear_entity_cont entity {
    local .skip_clear
    cmp [entity#.moved], 0
    je .skip_clear
    
    mov ax, [entity#.old_x]
    mov bx, [entity#.old_y]
    clear_entity
    mov ax, [entity#.x]
    mov bx, [entity#.y]
    clear_entity
    
    .skip_clear:
}

macro clear_entity_bg entity {
    local .skip_clear
    cmp [entity#.moved], 0
    je .skip_clear
        
    push cx
    push dx

    mov cx, [entity#.tile_x]
    mov dx, [entity#.tile_y]

    call draw_tile
    dec cx
    call draw_tile
    dec cx
    call draw_tile
    add cx, 3
    call draw_tile
    inc cx
    call draw_tile
    sub cx, 2
    
    dec dx
    call draw_tile
    dec dx
    call draw_tile
    add dx, 3
    call draw_tile
    inc dx
    call draw_tile
    sub dx, 2
    
    pop dx
    pop cx

    .skip_clear:
}

macro draw_entity entity {
    local .all_clear
    local .c_dir_up
    local .c_dir_left
    local .c_dir_down
    local .c_dir_right
    local .c_dead
    local .c_scared
    local .c_scared_2
    local .c_scared_end

    push dx

    ; clear_entity_bg entity

    cmp [pacman.state], 0
    je .all_clear
    jmp .c_dir_left
    .all_clear:

    mov dx, [entity]
    mov ax, [entity#.x]
    mov bx, [entity#.y]

    cmp [entity#.scared], 0
    je .c_scared_end
    mov cx, [entity#.scared]
    cmp cx, 48
    jg .c_scared_2
    and cx, 8
    test cx, cx
    jz .c_scared_2
    draw_anim_alpha scared_ghost_2, dx
    jmp .c_scared
    .c_scared_2:
    draw_anim_alpha scared_ghost, dx
    .c_scared:
    jmp .c_dir_left
    .c_scared_end:
    

    cmp [entity#.state], 3
    jne .c_dead
    mov dx, [entity#.dir]
    draw_anim_alpha dead_ghost, dx
    jmp .c_dir_left
    .c_dead:
    
    cmp [entity#.dir], 0
    jne .c_dir_up
    draw_anim_alpha entity#_go_up, dx
    .c_dir_up:

    cmp [entity#.dir], 1
    jne .c_dir_right
    draw_anim_alpha entity#_go_right, dx
    .c_dir_right:

    cmp [entity#.dir], 2
    jne .c_dir_down
    draw_anim_alpha entity#_go_down, dx
    .c_dir_down:

    cmp [entity#.dir], 3
    jne .c_dir_left
    draw_anim_alpha entity#_go_left, dx
    .c_dir_left:

    pop dx
}

macro to_spawn entity {
    to_tile [entity#.s_x], [entity#.s_y]
    sub ax, 4

    mov [entity#.x], ax
    mov [entity#.y], bx

    mov [entity#.tick], 1
    mov [entity#.speed], 3
    mov al, [entity#.s_state]
    mov [entity#.state], al
    mov ax, [entity#.s_dir]
    mov [entity#.s_dir], ax
    mov [entity#.old_dir], 5

    mov ax, [entity#.s_x]
    mov bx, [entity#.s_y]
    mov [entity#.tile_x], ax
    mov [entity#.tile_y], bx
}

get_random:
    push dx
    mov ah, 2Ch
    int 21h
    mov ax, dx
    mov dx, [random]
    shr ax, 2
    xor ax, dx
    mov [random], ax
    pop dx
    ret

draw_pacman:

    cmp [pacman.state], 0
    je .dead
    push ax
    push bx

    mov ax, [pacman.x]
    mov bx, [pacman.y]
    clear_entity
    draw_anim pacman_death, [pacman.state]

    pop bx
    pop ax

    jmp .end
    .dead:

    draw_entity pacman
    .end:
    ret

draw_red_ghost:
    draw_entity red_ghost
    ret

draw_pink_ghost:
    draw_entity pink_ghost
    ret

draw_cyan_ghost:
    draw_entity cyan_ghost
    ret

draw_yellow_ghost:
    draw_entity yellow_ghost
    ret

clear_all:
    clear_entity_cont red_ghost
    clear_entity_cont pink_ghost
    clear_entity_cont cyan_ghost
    clear_entity_cont yellow_ghost
    clear_entity_cont pacman

    clear_entity_bg red_ghost
    clear_entity_bg pink_ghost
    clear_entity_bg cyan_ghost
    clear_entity_bg yellow_ghost
    clear_entity_bg pacman
    
    ret

start_game:
    push ax
    push bx
    push cx
    push es
    push di

    mov ax, storage
    mov ds, ax

    to_tile 0, 9
    draw high_score_label

    to_tile 0, 3
    mov ecx, 1
    call draw_number

    to_tile 0, 4
    draw player_label

    to_tile 3, 0
    draw background

    mov si, tiles
    mov cx, 0
    .tile_x_loop:
        mov dx, 0
        .tile_y_loop:
            call draw_tile
            inc dx
            cmp dx, 28
            jne .tile_y_loop

        inc cx
        cmp cx, 34
        jne .tile_x_loop

    call draw_score

    to_tile 26, 13
    sub ax, 4

    mov [pacman.x], ax
    mov [pacman.y], bx

    draw_anim pacman_go_right, 0

    to_spawn red_ghost
    call draw_red_ghost

    to_spawn pink_ghost
    call draw_pink_ghost

    to_spawn cyan_ghost
    call draw_cyan_ghost

    to_spawn yellow_ghost
    call draw_yellow_ghost

    to_tile 20, 11
    draw ready_label

    call wait_for_keypress

    to_tile 20, 11
    clear ready_label
    
    .game_loop:
        cmp [pacman.state], 11
        je .gg

        call dispatch_events

        cmp [quit], 1
        je .break

        call move_red_ghost
        call move_pink_ghost
        call move_cyan_ghost
        call move_yellow_ghost
        call move_pacman
        
        call clear_all
        call draw_exit
        call draw_red_ghost
        call draw_pink_ghost
        call draw_cyan_ghost
        call draw_yellow_ghost
        call draw_pacman

        wait_t
        loop .game_loop

    .gg:

    call draw_game_over
    call wait_for_keypress

    .break:

    pop es
    pop di
    pop cx
    pop bx
    pop ax

    ret

get_tile:
    push ax
    push bx
    push dx

    mov dx, 28
    mul dx
    add ax, bx

    mov cl, [tiles + eax]

    xor ch, ch

    pop dx
    pop bx
    pop ax
    ret

set_tile:
    push ax
    push bx
    push dx

    mov dx, 28
    mul dx
    add ax, bx

    mov [tiles + eax], cl

    pop dx
    pop bx
    pop ax
    ret

; draws tile at (cx, dx)
draw_tile:
    push ax
    push bx
    push cx
    push dx

    mov ax, cx
    mov bx, dx
    
    push cx

    call get_tile

    mov ax, cx
    pop cx

    cmp ax, 7
    jne .small_pellet
    to_tile cx, dx
    draw small_pellet
    jmp .end
    .small_pellet:

    cmp ax, 15
    jne .large_pellet
    to_tile cx, dx
    draw large_pellet
    jmp .end
    .large_pellet:

    and ax, 12
    jz .empty
    to_tile cx, dx
    clear_rect 8, 8
    jmp .end
    .empty:

    .end:
    
    pop dx
    pop cx
    pop bx
    pop ax

    ret

dispatch_events:
    push ax
    push bx
    push ecx

    call check_for_keypress

    cmp ah, 48h
    jne .c_dir_up
    mov [pacman.dir], 0
    .c_dir_up:

    cmp ah, 4Dh
    jne .c_dir_right
    mov [pacman.dir], 1
    .c_dir_right:

    cmp ah, 50h
    jne .c_dir_down
    mov [pacman.dir], 2
    .c_dir_down:

    cmp ah, 4Bh
    jne .c_dir_left
    mov [pacman.dir], 3
    .c_dir_left:

    cmp ah, 01h
    jne .c_quit

    mov [quit], 1
    
    .c_quit:

    pop ecx
    pop bx
    pop ax

    ret

; draws number in ecx strating at (ax, bx)
draw_number:
    sub bx, 40
    clear_rect 48, 8
    add bx, 40

    push eax
    push bx
    push ecx
    push edx

    .out_loop:
        push eax
        mov eax, ecx
        xor edx, edx
        mov ecx, 10
        div ecx
        mov ecx, eax
        pop eax

        draw_anim digits, dx
        sub bx, 8

        test ecx, ecx
        jnz .out_loop

    pop edx
    pop ecx
    pop bx
    pop eax
    ret

draw_exit:
    push ax
    push bx

    to_tile 15, 13

    add ax, 5

    draw exit

    pop bx
    pop ax
    ret

draw_score:
    push ecx

    mov ecx, [points]
    to_tile 1, 5
    call draw_number
    
    to_tile 1, 18
    call draw_number

    pop ecx
    ret

draw_game_over:
    push ax
    push bx

    to_tile 20, 10
    sub bx, 4
    draw game_over_label

    pop bx
    pop ax
    ret

eat:
    push ax
    push bx
    push ecx
    push edx

    mov ax, [pacman.tile_x]
    mov bx, [pacman.tile_y]

    push ax
    push bx

    call get_tile

    mov bx, cx

    mov ax, bx
    mov ecx, [points]
    and ax, 12
    cmp ax, 12
    jne .large_pellet
    add ecx, 50
    xor bx, 12
    mov [red_ghost.scared], scare_time
    mov [pink_ghost.scared], scare_time
    mov [cyan_ghost.scared], scare_time
    mov [yellow_ghost.scared], scare_time
    mov [streak], 0
    jmp .end
    .large_pellet:
    
    mov ax, bx
    and ax, 4
    jz .pellet
    add ecx, 10
    xor bx, 4
    jmp .end
    .pellet:

    mov ax, bx
    and ax, 8
    jz .fruit
    mov ax, [fruits.next]
    mov dx, [fruits + eax]
    inc ax
    and ax, 15
    mov [fruits.next], ax
    add ecx, edx
    xor bx, 8
    jmp .end
    .fruit:

    .end:

    mov [points], ecx

    mov cx, bx

    pop bx
    pop ax

    call set_tile

    pop edx
    pop ecx
    pop bx
    pop ax

    call draw_score

    ret
