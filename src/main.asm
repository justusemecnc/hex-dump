default rel
%include "const.inc"

extern exitStatus
extern _parseArgs

section .text
global _start

; kernel gives us argc/argv on the stack — not in rdi/rsi like a normal call
_start:
    mov rdi, [rsp]
    lea rsi, [rsp + 8]
    call _parseArgs

    mov edi, [exitStatus]
    mov rax, SYS_EXIT
    syscall
