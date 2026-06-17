default rel
%include "const.inc"

extern errBadArg, errBadArgLen
extern seekVal, limitVal, limitSet, exitStatus
extern streamOffset, carryCount, didDump, streamInit
extern skipRemaining, bytesLeft
extern _parseU64, _writeErr
extern _beginStream, _dumpStdin, _dumpFile
extern _flushCarry, _printFooter

section .text
global _parseArgs

; rdi=argc, rsi=argv
_parseArgs:
    push r12
    push r13
    push r14
    push rbx

    mov qword [seekVal], 0
    mov qword [limitVal], 0
    mov byte [limitSet], 0
    mov dword [exitStatus], EXIT_OK
    mov qword [streamOffset], 0
    mov qword [carryCount], 0
    mov byte [didDump], 0
    mov byte [streamInit], 0
    mov qword [skipRemaining], 0
    mov qword [bytesLeft], -1

    mov r12, rdi
    mov r13, rsi
    xor r14, r14

    mov rbx, 1
.argLoop:
    cmp rbx, r12
    jge .afterArgs

    mov rdi, [r13 + rbx * 8]

    cmp byte [rdi], '-'
    jne .isFile

    cmp byte [rdi + 1], 'n'
    je .flagN
    cmp byte [rdi + 1], 's'
    je .flagS
    cmp byte [rdi + 1], 0
    jne .badFlag
    jmp .isFile

.flagN:
    cmp byte [rdi + 2], 0
    jne .badFlag
    inc rbx
    cmp rbx, r12
    jge .badFlag
    mov rdi, [r13 + rbx * 8]
    call _parseU64
    jc .badFlag
    mov [limitVal], rax
    mov [bytesLeft], rax
    mov byte [limitSet], 1
    inc rbx
    jmp .argLoop

.flagS:
    cmp byte [rdi + 2], 0
    jne .badFlag
    inc rbx
    cmp rbx, r12
    jge .badFlag
    mov rdi, [r13 + rbx * 8]
    call _parseU64
    jc .badFlag
    mov [seekVal], rax
    inc rbx
    jmp .argLoop

.badFlag:
    mov rsi, errBadArg
    mov rdx, errBadArgLen
    call _writeErr
    mov dword [exitStatus], EXIT_USAGE
    jmp .done

.isFile:
    cmp byte [rdi], '-'
    jne .regular
    cmp byte [rdi + 1], 0
    jne .regular
    inc r14
    call _beginStream
    call _dumpStdin
    inc rbx
    jmp .argLoop
.regular:
    inc r14
    call _dumpFile
    inc rbx
    jmp .argLoop

.afterArgs:
    test r14, r14
    jnz .maybeFooter
    call _beginStream
    call _dumpStdin

.maybeFooter:
    call _flushCarry
    cmp byte [didDump], 0
    je .done
    call _printFooter

.done:
    pop rbx
    pop r14
    pop r13
    pop r12
    ret
