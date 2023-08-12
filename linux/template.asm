format ELF executable

entry _start

segment readable executable

_start:
    xor ebx, ebx
    mov eax, ebx

    inc eax

    int 0x80

segment readable writable 
    db 0