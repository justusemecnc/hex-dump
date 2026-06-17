default rel
%include "const.inc"

section .text
global _emitLine, _beginStream, _markDumped, _feedBytes, _flushCarry

extern lineBuf, carryBuf, carryCount
extern streamOffset, skipRemaining, bytesLeft
extern seekVal, didDump, streamInit
extern _formatLine, _writeFd

; format + write one line to stdout
_emitLine:
    call _formatLine
    call _markDumped
    mov rdi, 1
    mov rsi, lineBuf
    mov rdx, rax
    jmp _writeFd

; first time we dump: pick up -s offset for display and skipping
_beginStream:
    cmp byte [streamInit], 0
    jne .ret
    mov rax, [seekVal]
    mov [streamOffset], rax
    mov [skipRemaining], rax
    mov byte [streamInit], 1
.ret:
    ret

_markDumped:
    mov byte [didDump], 1
    ret

; take rsi/rdx bytes from a read or mmap and turn them into lines
; handles -s skip, -n limit, and carry-over between files
_feedBytes:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rsi
    mov r13, rdx
    mov r15, [carryCount]

.feedLoop:
    test r13, r13
    jz .done

    ; burn through -s bytes without printing
    cmp qword [skipRemaining], 0
    je .limitCheck

    mov r14, [skipRemaining]
    cmp r14, r13
    jbe .skipTake
    mov r14, r13
.skipTake:
    sub r13, r14
    sub qword [skipRemaining], r14
    add r12, r14
    jmp .feedLoop

.limitCheck:
    cmp qword [bytesLeft], 0
    je .done

    mov r15, [carryCount]
    cmp r15, CHUNK_SIZE
    jb .hasRoom
    mov rsi, [streamOffset]
    mov rdi, carryBuf
    mov rdx, CHUNK_SIZE
    call _emitLine
    add qword [streamOffset], CHUNK_SIZE
    mov qword [carryCount], 0
    mov r15, 0

.hasRoom:
    mov rax, CHUNK_SIZE
    sub rax, r15
    mov r14, r13
    cmp r14, rax
    jbe .take
    mov r14, rax
.take:
    cmp qword [bytesLeft], 0
    jl .copy
    mov rax, [bytesLeft]
    cmp r14, rax
    jbe .copy
    mov r14, rax

.copy:
    test r14, r14
    jz .feedLoop
    movzx eax, byte [r12]
    mov [carryBuf + r15], al
    inc r12
    inc r15
    dec r13
    dec r14
    cmp qword [bytesLeft], 0
    jl .copy
    dec qword [bytesLeft]
    jmp .copy

.done:
    mov [carryCount], r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; last partial line if we stopped mid-chunk
_flushCarry:
    mov r15, [carryCount]
    test r15, r15
    jz .ret
    mov rsi, [streamOffset]
    mov rdi, carryBuf
    mov rdx, r15
    call _emitLine
    add [streamOffset], r15
    mov qword [carryCount], 0
.ret:
    ret
