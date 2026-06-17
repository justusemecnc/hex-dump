default rel
%include "const.inc"

section .text
global _byteToHex, _u64ToHex8, _isPrintable, _formatLine, _printFooter

extern hexDigits, sep2, pipeOpen, pipeClose
extern lineBuf, streamOffset
extern _writeFd

; one byte in sil -> two chars at rdi (uses r10b, not bl — rbx holds line ptr)
_byteToHex:
    movzx rax, sil
    mov rcx, rax
    shr rcx, 4
    and rax, 0x0F
    mov r10b, [hexDigits + rcx]
    mov [rdi], r10b
    mov r10b, [hexDigits + rax]
    mov [rdi + 1], r10b
    ret

; 64-bit offset in rsi -> 8 hex digits at rdi
_u64ToHex8:
    mov rax, rsi
    mov rcx, 7
.loop:
    mov rdx, rax
    and rdx, 0x0F
    mov r10b, [hexDigits + rdx]
    mov [rdi + rcx], r10b
    shr rax, 4
    dec rcx
    jns .loop
    ret

; printable ascii or dot
_isPrintable:
    cmp al, 32
    jl .dot
    cmp al, 126
    jg .dot
    ret
.dot:
    mov al, '.'
    ret

; build one hexdump -C line in lineBuf
; rsi=offset, rdi=data, rdx=count (1..16), rax=line len
_formatLine:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rsi
    mov r13, rdi
    mov r14, rdx
    mov rbx, lineBuf

    mov rdi, rbx
    mov rsi, r12
    call _u64ToHex8
    add rbx, 8

    mov ax, [sep2]
    mov [rbx], ax
    add rbx, 2

    mov r8, rbx

    xor r15, r15
.hexLoop:
    cmp r15, r14
    jge .hexPad
    movzx eax, byte [r13 + r15]
    mov rdi, rbx
    mov sil, al
    call _byteToHex
    mov byte [rbx + 2], ' '
    add rbx, 3
    inc r15
    cmp r15, 8
    jne .hexLoop
    mov byte [rbx], ' '
    inc rbx
    jmp .hexLoop

.hexPad:
    ; pad hex column to 49 chars so the ascii block lines up
    mov r15, rbx
    sub r15, r8
    cmp r15, 49
    jge .asciiBlock
    mov byte [rbx], ' '
    inc rbx
    jmp .hexPad

.asciiBlock:
    mov ax, [pipeOpen]
    mov [rbx], ax
    add rbx, 2

    xor r15, r15
.asciiLoop:
    cmp r15, r14
    jge .asciiEnd
    movzx eax, byte [r13 + r15]
    call _isPrintable
    mov [rbx], al
    inc rbx
    inc r15
    jmp .asciiLoop

.asciiEnd:
    mov ax, [pipeClose]
    mov [rbx], ax
    add rbx, 2

    mov rax, rbx
    sub rax, lineBuf

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; trailing offset line that hexdump -C prints at the end
_printFooter:
    mov rdi, lineBuf
    mov rsi, [streamOffset]
    call _u64ToHex8
    mov byte [lineBuf + 8], 10
    mov rdi, 1
    mov rsi, lineBuf
    mov rdx, 9
    jmp _writeFd
