section .data

    hello: db "First word", 10
    wordLen: equ $-hello

section .text
    global _start

_start:
    mov rax, 4
    mov rbx, 1
    mov rcx, hello
    mov rdx, wordLen

    int 80h

    mov rax, 1
    mov rbx, 0

    int 80h