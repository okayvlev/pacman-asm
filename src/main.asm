format MZ
entry main:start
stack 100h
use16


segment storage

    include "./gamedata.asm"
    vd_mode         dw 0103h ; graphic mode 800x600 256 colors
    screen_width    equ 800
    texture_bitmap  file "res/bitmap.bmp"
        .width      dw 320
        .height     dw 248
    include "res/texturemaps.asm"

segment bss
    mem    db 200000 dup (?)

segment main

include "./videodriver.asm"
include "./keyboarddriver.asm"
include "./texturedrawer.asm"
include "./gamecore.asm"
include "./gamestrategy.asm"

start:
    
    call load_textures


    mov ax, storage
    mov ds, ax
    mov si, 0

    call vd_init
    
    mov si, texture_bitmap
    add si, word 036h
    call vd_set_bmp_palette

    mov ax, bss
    mov ds, ax
    mov si, mem

    call start_game

    .end:

    xor bx, bx
    xor cx, cx
    xor dx, dx

    mov al, 0
    mov ah, 4Ch

    int 21h

    ret

load_textures:
    mov ax, storage
    mov ds, ax
    mov si, texture_bitmap
    add si, 03AAh

    mov ax, bss
    mov es, ax
    mov di, mem
    
    call align_di_segment

    load background
    load player_label
    load exit
    load game_over_label
    load high_score_label
    load ready_label
    load small_pellet
    load large_pellet

    load_anim digits, 10
    load_anim pacman_go_left, 4
    load_anim pacman_go_right, 4
    load_anim pacman_go_up, 4
    load_anim pacman_go_down, 4
    load_anim pacman_death, 12

    load_anim red_ghost_go_left, 4
    load_anim red_ghost_go_right, 4
    load_anim red_ghost_go_up, 4
    load_anim red_ghost_go_down, 4

    load_anim pink_ghost_go_left, 4
    load_anim pink_ghost_go_right, 4
    load_anim pink_ghost_go_up, 4
    load_anim pink_ghost_go_down, 4

    load_anim cyan_ghost_go_left, 4
    load_anim cyan_ghost_go_right, 4
    load_anim cyan_ghost_go_up, 4
    load_anim cyan_ghost_go_down, 4

    load_anim yellow_ghost_go_left, 4
    load_anim yellow_ghost_go_right, 4
    load_anim yellow_ghost_go_up, 4
    load_anim yellow_ghost_go_down, 4

    load_anim scared_ghost, 4
    load_anim scared_ghost_2, 4

    load_anim dead_ghost, 4
    
    load_anim void, 4

    ret

; maximizes ds and minimizes si 
align_si_segment:
    push ax
    push bx

    mov ax, si
    and si, 0Fh

    shr ax, 4
    mov bx, ds
    add ax, bx
    mov ds, ax

    pop bx
    pop ax

    ret

; maximizes es and minimizes di 
align_di_segment:
    push ax
    push bx

    mov ax, di
    and di, 0Fh

    shr ax, 4
    mov bx, es
    add ax, bx
    mov es, ax

    pop bx
    pop ax

    ret

; output eax in decimal
output_dec:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, 10

    .out_loop:
        xor edx, edx
        div ecx

        push eax
        push edx
        mov ah, 02h
        add dl, '0'
        int 21h
        pop edx
        pop eax

        test eax, eax
        jnz .out_loop
    
    mov ah, 02h
    mov dl, 10
    int 21h

    pop edx
    pop ecx
    pop ebx
    pop eax

    ret
