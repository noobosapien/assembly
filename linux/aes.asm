format ELF executable

entry _start

segment readable executable

_start:
    xor ebx, ebx
    mov eax, ebx

    inc eax

    int 0x80

    lea esi, [k]
    lea edi, [s]

    mov ecx, 4
    rep movsd

    call aes_set_encrypt_key

    lea esi, [s]
    lea edi, [I]
    lea eax, [d]

    movups xmm0, [eax]

    call aes_encrypt

    push 0
    ; call[exitProcess]

aes_encrypt:
    mov ecx, 9
    movups xmm1, [esi]
    add esi, 0x10
    pxor xmm0, xmm1

.encryption_loop:
    movups xmm1, [esi]
    add esi, 0x10
    aesenc xmm0, xmm1
    loop .encryption_loop

    movups xmm1, [esi]
    aesenclast xmm0, xmm1

    lea edi, [I]
    movups [edi], xmm0
    ret

aes_set_encrypt_key:
    aeskeygenassist xmm2, xmm1, 1
    call key_expand

    aeskeygenassist xmm2, xmm1, 2
    call key_expand

    aeskeygenassist xmm2, xmm1, 4
    call key_expand

    aeskeygenassist xmm2, xmm1, 8
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x10
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x20
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x40
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x80
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x1b
    call key_expand

    aeskeygenassist xmm2, xmm1, 0x36
    call key_expand

    ret

key_expand:

    pshufd xmm2, xmm2, 0xff
    vpslldq xmm3, xmm1, 0x04

    pxor xmm1, xmm3
    vpslldq xmm3, xmm1, 0x04
    pxor xmm1, xmm3
    vpslldq xmm3, xmm1, 0x04
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movups [edi], xmm1
    add edi, 0x10
    ret

segment readable writable 
    d db 0,1,2,3,4,5,6,7,8,9,0xa,0xb,0xc,0xd,0xe,0xf

    k db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

    s rb 16 * 11

    I rb 16