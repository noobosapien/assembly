format ELF executable

entry _start

segment readable executable

_start:

    xor ebx, ebx ; xor same register makes it 0
    mov eax, ebx ; copy 0 from ebx to eax

    inc eax ; increment value of eax by 1

    int 0x80 ; system call 0x80

    lea esi, [k] ; store "k" address at esi
    lea edi, [s]

    mov ecx, 4
    rep movsd ; move double word from edi location to ecx
    ;rep is used to indicate use ecx as a counter
    call aes_set_encrypt_key ; call this procedure

    lea esi, [s]
    lea edi, [I]
    lea eax, [d]

    movups xmm0, [eax]

    call aes_encrypt

    push 0 ; save 0 on stack
    ; call[exitProcess]

aes_encrypt:
    mov ecx, 9
    movups xmm1, [esi]
    add esi, 0x10
    pxor xmm0, xmm1

.encryption_loop:
    movups xmm1, [esi]
    add esi, 0x10
    aesenc xmm0, xmm1 ; perform AES encryption
    loop .encryption_loop

    movups xmm1, [esi]
    aesenclast xmm0, xmm1 ; last round of AES encryption

    lea edi, [I]
    movups [edi], xmm0
    ret ; return from procedure to one who called, pops stack to instruction pointer register

aes_set_encrypt_key:
    aeskeygenassist xmm2, xmm1, 1 ; assist AES generation using 8 bit round constant
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

    pushfd xmm2, xmm2, 0xff ; push flags into stack
    vpslldq xmm3, xmm1, 0x04 ; shift xmm1 4 bytes left and store it in xmm3

    pxor xmm1, xmm3
    vpslldq xmm3, xmm1, 0x04
    pxor xmm1, xmm3
    vpslldq xmm3, xmm1, 0x04
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movups [edi], xmm1
    add edi, 0x10 ; add 0x10 to edi
    ret

segment readable writable 
    d db 0,1,2,3,4,5,6,7,8,9,0xa,0xb,0xc,0xd,0xe,0xf ;declare byte

    k db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; declare byte
 
    s rb 16 * 11 ;reserve byte with this size

    I rb 16 ;reserve byte with this size