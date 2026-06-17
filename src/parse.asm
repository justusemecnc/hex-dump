default rel
%include "const.inc"

extern exitStatus

section .text
global _parseU64

; parse rdi as decimal or 0x hex, result in rax
; carry set + exit 2 on bad input
_parseU64:
    xor rax, rax
    mov r8b, 10
    cmp byte [rdi], '0'
    jne .digits
    mov cl, [rdi + 1]
    cmp cl, 'x'
    je .hexPrefix
    cmp cl, 'X'
    je .hexPrefix
    jmp .digits
.hexPrefix:
    add rdi, 2
    mov r8b, 16
.digits:
    movzx r9, byte [rdi]
    test r9, r9
    jz .ok
    cmp r9, '0'
    jl .bad
    cmp r9, '9'
    jle .dec
    cmp r8b, 16
    jne .bad
    cmp r9, 'a'
    jl .checkHexUpper
    cmp r9, 'f'
    jle .hexLower
.bad:
    mov dword [exitStatus], EXIT_USAGE
    mov rax, 0
    stc
    ret
.checkHexUpper:
    cmp r9, 'A'
    jl .bad
    cmp r9, 'F'
    jg .bad
    sub r9, 'A' - 10
    jmp .accum
.hexLower:
    sub r9, 'a' - 10
    jmp .accum
.dec:
    sub r9, '0'
.accum:
    push rdi
    movzx rcx, r8b
    mul rcx
    add rax, r9
    pop rdi
    inc rdi
    jmp .digits
.ok:
    clc
    ret
