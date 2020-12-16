
macro to_tile_pos {
    to_tile ax, bx
    sub ax, 4
    sub bx, 4
}

macro reset_pos entity {
    local .spawn

    cmp [entity#.old_dir], 5
    je .spawn

    pop bx
    pop ax

    push ax
    push bx

    to_tile_pos

    mov [entity#.x], ax
    mov [entity#.y], bx

    .spawn:
}

macro tile_check entity {
    local .stop
    local .new_dir

    call get_tile
    and cx, 1
    jnz .stop

    reset_pos entity

    mov ax, 0
    mov cx, [entity#.old_dir]
    cmp cx, [entity#.dir]
    je .new_dir
    mov [entity#.dir], cx
    mov ax, 2
    jmp .stop
    .new_dir:

    mov ax, 1

    .stop:
}

macro move_entity entity {
    local .correct_pos
    local .c_dir_up
    local .c_dir_right
    local .c_dir_down
    local .c_dir_left
    local .upd
    local .undo
    local .is_moved
    local .not_moved
    local .end
    local .tele
    local .tele_left
    local .tele_right
    local .to_left
    local .to_right


    push ax
    push bx
    push cx

    mov [entity#.moved], 0

    mov ax, [entity#.x]
    mov bx, [entity#.y]

    mov [entity#.old_x], ax
    mov [entity#.old_y], bx

    mov ax, [entity#.tile_x]
    mov bx, [entity#.tile_y]

    push ax
    push bx

    cmp ax, 17
    jne .tele

    cmp bx, 0
    je .tele_left

    cmp bx, 27
    je .tele_right

    jmp .tele

    .tele_left:

    cmp [entity#.dir], 3
    jne .tele

    mov bx, [entity#.y]
    sub bx, [entity#.speed]
    mov [entity#.y], bx

    cmp bx, 80
    jg .to_right
    add bx, 222

    mov [entity#.y], bx
    mov [entity#.tile_y], 27
    .to_right:

    jmp .upd
    .tele_right:

    cmp [entity#.dir], 1
    jne .tele

    mov bx, [entity#.y]
    add bx, [entity#.speed]
    mov [entity#.y], bx

    cmp bx, 303
    jb .to_left
    sub bx, 222

    mov [entity#.y], bx
    mov [entity#.tile_y], 0
    .to_left:

    jmp .upd
    .tele:



    mov ax, [entity#.tile_x]
    mov bx, [entity#.tile_y]

    mov cx, [entity#.old_dir]
    cmp cx, [entity#.dir]
    je .correct_pos
    push ax
    push bx
    reset_pos entity
    pop bx
    pop ax
    .correct_pos:

    cmp [entity#.dir], 0
    jne .c_dir_up

    dec ax
    tile_check entity
    cmp ax, 1
    je .upd
    cmp ax, 2
    je .undo

    mov bx, [entity#.x]
    sub bx, [entity#.speed]
    mov [entity#.x], bx
    .c_dir_up:

    cmp [entity#.dir], 1
    jne .c_dir_right

    inc bx
    tile_check entity
    cmp ax, 1
    je .upd
    cmp ax, 2
    je .undo

    mov bx, [entity#.y]
    add bx, [entity#.speed]
    mov [entity#.y], bx
    .c_dir_right:
    
    cmp [entity#.dir], 2
    jne .c_dir_down

    inc ax
    tile_check entity
    cmp ax, 1
    je .upd
    cmp ax, 2
    je .undo
    
    mov bx, [entity#.x]
    add bx, [entity#.speed]
    mov [entity#.x], bx
    .c_dir_down:
    
    cmp [entity#.dir], 3
    jne .c_dir_left

    dec bx
    tile_check entity
    cmp ax, 1
    je .upd
    cmp ax, 2
    je .undo
    
    mov bx, [entity#.y]
    sub bx, [entity#.speed]
    mov [entity#.y], bx
    .c_dir_left:

    .upd:

    mov ax, [entity#.dir]
    mov [entity#.old_dir], ax

    mov ax, [entity#.x]
    mov bx, [entity#.y]
    
    from_coords

    mov [entity#.tile_x], ax
    mov [entity#.tile_y], bx

    jmp .end

    .undo:
    
    pop bx
    pop ax

    mov ax, [entity#.old_x]
    mov bx, [entity#.old_y]

    mov [entity#.x], ax
    mov [entity#.y], bx

    pop cx
    pop bx
    pop ax

    call move_#entity

    ret

    .end:

    pop bx
    pop ax

    mov ax, [entity#.old_x]
    mov bx, [entity#.old_y]

    cmp bx, [entity#.y]
    jne .is_moved
    cmp ax, [entity#.x]
    jne .is_moved

    jmp .not_moved

    .is_moved:
    mov [entity#.moved], 1

    mov ax, [entity]
    inc ax
    and ax, 3
    mov [entity], ax

    .not_moved:

    pop cx
    pop bx
    pop ax

}


move_pacman:

    cmp [pacman.state], 0
    je .dead
    mov cx, [pacman.state]
    inc cx
    cmp cx, 12
    je .eat
    mov [pacman.state], cx
    jmp .eat
    .dead:


    move_entity pacman

    mov ax, [pacman.tile_x]
    mov bx, [pacman.tile_y]

    call get_tile

    and cx, 12

    jz .eat
    call eat
    .eat:

    ret

macro get_tile_up {
    dec ax
    call get_tile
    inc ax
}

macro get_tile_right {
    inc bx
    call get_tile
    dec bx
}

macro get_tile_down {
    inc ax
    call get_tile
    dec ax
}
macro get_tile_left {
    dec bx
    call get_tile
    inc bx
}

macro pick_default_dir ghost {
    local .skip
    local .move_up
    local .move_right
    local .move_down
    local .move_left
    local .go_forward
    local .target

    push ax
    push bx
    push cx
    push dx

    mov ax, [ghost#.dir_cooldown] 
    test ax, ax
    jz .skip
    dec ax
    mov [ghost#.dir_cooldown], ax
    jmp .go_forward
    .skip:

    mov ax, [ghost#.tile_x]
    mov bx, [ghost#.tile_y]

    xor dx, dx
    get_tile_up
    and cx, 1
    add dx, cx
    get_tile_right
    and cx, 1
    add dx, cx
    get_tile_down
    and cx, 1
    add dx, cx
    get_tile_left
    and cx, 1
    add dx, cx

    mov cx, dx

    mov dx, [ghost#.dir]
    add dx, 2
    and dx, 3


    cmp cx, 3
    jb .target

    local .target_up
    local .target_right
    local .target_down
    local .target_left

    cmp bx, [ghost#.target_y]
    jbe .target_left
    cmp dx, 3
    je .target_left
    get_tile_left
    and cx, 1
    test cx, cx
    jz .target_left
    mov [ghost#.dir], 3
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .target_left:

    cmp bx, [ghost#.target_y]
    jge .target_right
    cmp dx, 1
    je .target_right
    get_tile_right
    and cx, 1
    test cx, cx
    jz .target_right
    mov [ghost#.dir], 1
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .target_right:

    cmp ax, [ghost#.target_x]
    jbe .target_up
    cmp dx, 0
    je .target_up
    get_tile_up
    and cx, 1
    test cx, cx
    jz .target_up
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    mov [ghost#.dir], 0
    jmp .go_forward
    .target_up:

    cmp ax, [ghost#.target_x]
    jge .target_down
    cmp dx, 2
    je .target_down
    get_tile_down
    and cx, 1
    test cx, cx
    jz .target_down
    mov [ghost#.dir], 2
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .target_down:

    .target:

    cmp dx, 0
    je .move_up
    get_tile_up
    and cx, 1
    jz .move_up
    mov [ghost#.dir], 0
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .move_up:


    cmp dx, 1
    je .move_right
    get_tile_right
    and cx, 1
    jz .move_right
    mov [ghost#.dir], 1
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .move_right:

    cmp dx, 2
    je .move_down
    get_tile_down
    and cx, 1
    jz .move_down
    mov [ghost#.dir], 2
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .move_down:

    cmp dx, 3
    je .move_left
    get_tile_left
    and cx, 1
    jz .move_left
    mov [ghost#.dir], 3
    mov cx, [ghost_dir_cooldown]
    mov [ghost#.dir_cooldown], cx
    jmp .go_forward
    .move_left:

    .go_forward:

    pop dx
    pop cx
    pop bx
    pop ax

}

macro move_ghost ghost {
    local .overflow
    local .up
    local .down
    local .turn_up
    local .turn_down
    local .waiting
    local .emerging
    local .move_up
    local move_side
    local .cyan
    local .yellow
    local .chasing
    local .target
    local .dead
    local .eq_x
    local .eq_y
    local .eat
    local .sc_cnt
    local .end

    cmp [pacman.state], 0
    jne .end

    push ax
    push bx
    push cx
    push dx

    mov ax, [ghost#.x]
    mov bx, [ghost#.y]

    mov [ghost#.old_x], ax
    mov [ghost#.old_y], bx

    mov dx, [ghost#.tick]
    inc dx
    cmp dx, 10
    jne .overflow
    mov dx, 0
    .overflow:
    mov [ghost#.tick], dx

    cmp [ghost#.state], 0 ; waiting
    jne .waiting
    mov [ghost#.moved], 1

    local .try_emerging
    cmp [ghost#.tick], 1
    jne .try_emerging
    call get_random
    and ax, 5
    test ax, ax
    jnz .try_emerging
    mov [ghost#.state], 1
    .try_emerging:
    

    mov ax, [ghost#.x]
    mov bx, [ghost#.y]

    mov [ghost#.old_x], ax
    mov [ghost#.old_y], bx

    cmp dx, 5
    jge .up
    
    cmp dx, 4
    jne .turn_down
    mov [ghost#.dir], 2
    jmp .waiting
    .turn_down:

    mov ax, [ghost#.x]
    sub ax, 2
    mov [ghost#.x], ax

    jmp .waiting
    .up:

    cmp dx, 5
    jb .down 
    cmp dx, 9
    jne .turn_up
    mov [ghost#.dir], 0
    jmp .waiting
    .turn_up:

    mov ax, [ghost#.x]
    add ax, 2
    mov [ghost#.x], ax

    .down:

    .waiting:

    cmp [ghost#.state], 1 ; emerging
    jne .emerging
    mov [ghost#.moved], 1

    cmp dx, 6
    jb .move_up
    mov [ghost#.dir], 0
    mov ax, [ghost#.x]
    sub ax, 6
    mov [ghost#.x], ax
    cmp dx, 9
    jne .emerging
    mov [ghost#.state], 2
    to_tile 14, 13
    sub ax, 4
    mov [ghost#.x], ax
    mov [ghost#.y], bx
    mov [ghost#.dir], 3
    mov [ghost#.old_dir], 3
    mov [ghost#.tile_x], 14
    mov [ghost#.tile_y], 13
    jmp .chasing

    .move_up:
    
    cmp dx, 6
    jge .move_side
    
    cmp [ghost#.tile_y], 15
    je .cyan
    mov [ghost#.dir], 1
    mov bx, [ghost#.y]
    add bx, 3
    mov [ghost#.y], bx
    .cyan:
    
    cmp [ghost#.tile_y], 11
    je .yellow
    mov [ghost#.dir], 3
    mov bx, [ghost#.y]
    sub bx, 3
    mov [ghost#.y], bx
    .yellow:

    .move_side:
    
    .emerging:

    cmp [ghost#.state], 2 ; chasing
    jne .chasing
    pick_default_dir ghost

    move_entity ghost
    .chasing:

    cmp [ghost#.state], 3 ; dead
    jne .dead
    mov [ghost#.speed], 5
    mov [ghost#.scared], 1 
    mov [ghost#.target_x], 14 
    mov [ghost#.target_y], 13

    pick_default_dir ghost

    move_entity ghost

    cmp [ghost#.tile_x], 14
    jne .dead

    cmp [ghost#.tile_y], 13
    jne .dead

    to_spawn ghost
    
    jmp .eq_x

    .dead:

    mov ax, [ghost#.tile_x]
    mov bx, [ghost#.tile_y]

    cmp ax, [pacman.tile_x]
    jne .eq_x
    cmp bx, [pacman.tile_y]
    jne .eq_y

    mov cx, [ghost#.scared]
    test cx, cx
    jz .eat

    cmp [ghost#.state], 3
    je .eq_x

    mov [ghost#.state], 3
    xor ecx, ecx
    mov cx, [streak]
    inc cx
    mov [streak], cx
    dec cx
    mov cx, [bonus + ecx * 2]
    add [points], ecx

    call draw_score

    jmp .eq_x

    .eat:

    mov [pacman.state], 1

    .eq_y:
    .eq_x:

    mov cx, [ghost#.scared]
    test cx, cx    
    jz .sc_cnt
    mov [ghost#.speed], 2
    mov [ghost_dir_cooldown], 2
    dec cx
    mov [ghost#.scared], cx

    test cx, cx
    jnz .sc_cnt

    mov [ghost_dir_cooldown], 1
    mov [ghost#.speed], 3

    .sc_cnt:


    pop dx
    pop cx
    pop bx
    pop ax

    .end:
}

move_red_ghost:
    push ax
    push bx
    mov ax, [pacman.tile_x]
    mov bx, [pacman.tile_y]
    mov [red_ghost.target_x], ax
    mov [red_ghost.target_y], bx
    pop bx
    pop ax

    move_ghost red_ghost

    ret

move_cyan_ghost:

    push ax
    push bx
    mov ax, [pacman.tile_x]
    mov bx, [pacman.tile_y]
    add ax, 4
    add bx, 4
    mov [cyan_ghost.target_x], ax
    mov [cyan_ghost.target_y], bx
    pop bx
    pop ax


    move_ghost cyan_ghost

    ret

move_pink_ghost:

    push ax
    push bx
    push cx
    push dx

    call get_random
    

    xor dx, dx
    mov cx, 8
    div cx
    mov bx, dx
    shl bx, 2

    call get_random

    xor dx, dx
    mov cx, 30
    div cx
    mov ax, dx
    shl ax, 2
    add ax, 4

    mov [pink_ghost.target_x], ax
    mov [pink_ghost.target_y], bx

    pop dx
    pop cx
    pop bx
    pop ax

    move_ghost pink_ghost

    ret

move_yellow_ghost:
    ; move_entity yellow_ghost

    push ax
    push bx
    mov ax, [pacman.tile_x]
    mov bx, [pacman.tile_y]
    sub ax, 4
    sub bx, 4
    mov [yellow_ghost.target_x], ax
    mov [yellow_ghost.target_y], bx
    pop bx
    pop ax

    move_ghost yellow_ghost

    ret

