default rel
%include "const.inc"

section .text
global _writeFd, _writeStr, _writeErr

; write(rdi=fd, rsi=buf, rdx=len)
_writeFd:
    mov rax, SYS_WRITE
    syscall
    ret

; write a null-terminated string; fd already in rdi
_writeStr:
    push rdi
    mov rcx, rsi
    xor rdx, rdx
.count:
    cmp byte [rcx + rdx], 0
    je .done
    inc rdx
    jmp .count
.done:
    mov rsi, rcx
    pop rdi
    jmp _writeFd

; stderr helper — rsi=msg, rdx=len
_writeErr:
    mov rdi, 2
    jmp _writeFd
