; if key is not available, al = 0 
check_for_keypress:
    xor ax, ax
    mov cx, 0

    .event_loop:

    mov ah, 01h
    int 16h

    jz .end

    mov ah, 0
    int 16h

    mov [last_key], ax

    jmp .event_loop

    .end:
    
    mov ax, [last_key]

    ret

wait_for_keypress:
    mov ah, 0
    int 16h 
    mov [last_key], ax
    
    ret