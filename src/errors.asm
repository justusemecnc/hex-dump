default rel
%include "const.inc"

extern errNotFound, errNotFoundLen
extern errPerm, errPermLen
extern errIsDir, errIsDirLen
extern errOpen, errOpenLen
extern exitStatus
extern _writeErr

section .text
global _openError
_openError:
    test rax, rax
    js .neg
    jmp .map
.neg:
    neg rax
.map:
    cmp rax, ENOENT
    je .notFound
    cmp rax, EACCES
    je .perm
    cmp rax, EISDIR
    je .isdir
    mov rsi, errOpen
    mov rdx, errOpenLen
    jmp .write
.notFound:
    mov rsi, errNotFound
    mov rdx, errNotFoundLen
    jmp .write
.perm:
    mov rsi, errPerm
    mov rdx, errPermLen
    jmp .write
.isdir:
    mov rsi, errIsDir
    mov rdx, errIsDirLen
.write:
    call _writeErr
    mov dword [exitStatus], EXIT_ERR
    ret
