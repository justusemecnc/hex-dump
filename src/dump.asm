default rel
%include "const.inc"

extern readBuf, statBuf, mapAddr, seekVal, exitStatus, bytesLeft
extern errIsDir, errIsDirLen
extern _feedBytes, _beginStream
extern _writeErr, _openError

section .text
global _dumpReadLoop, _dumpStdin, _dumpFile

; read fd in r12 until eof or -n runs out
_dumpReadLoop:
    push r12
    push r13
    push r14

.readLoop:
    cmp qword [bytesLeft], 0
    je .done

    mov r13, CHUNK_SIZE
    cmp qword [bytesLeft], 0
    jl .doRead
    cmp qword [bytesLeft], CHUNK_SIZE
    jge .doRead
    mov r13, [bytesLeft]

.doRead:
    mov rax, SYS_READ
    mov rdi, r12
    mov rsi, readBuf
    mov rdx, r13
    syscall
    test rax, rax
    jle .done

    mov r13, rax
    mov rsi, readBuf
    mov rdx, r13
    call _feedBytes
    jmp .readLoop

.done:
    pop r14
    pop r13
    pop r12
    ret

_dumpStdin:
    mov r12, 0
    jmp _dumpReadLoop

; rdi = path
_dumpFile:
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov rbx, rdi
    call _beginStream

    mov rax, SYS_OPEN
    mov rdi, rbx
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    js .openFail
    cmp rax, 3
    jl .openFail
    mov r12, rax

    mov qword [mapAddr], 0

    mov rax, SYS_FSTAT
    mov rdi, r12
    mov rsi, statBuf
    syscall
    js .closeFail

    mov eax, [statBuf + STAT_MODE]
    and eax, S_IFMT
    cmp eax, S_IFDIR
    je .dirFail

    ; size via lseek — stat buf is 144 bytes on x86-64, don't trust a smaller buffer
    mov rax, SYS_LSEEK
    mov rdi, r12
    xor rsi, rsi
    mov rdx, SEEK_END
    syscall
    js .useRead
    mov r15, rax
    mov rdi, r12
    xor rsi, rsi
    mov rdx, SEEK_SET
    mov rax, SYS_LSEEK
    syscall
    js .useRead
    test r15, r15
    jg .sizeOk
    xor r15, r15
.sizeOk:

    ; big files get mmap'd if we're not seeking — way fewer syscalls
    mov rax, [seekVal]
    test rax, rax
    jnz .useRead
    cmp r15, MMAP_THRESH
    jb .useRead

    mov rax, SYS_MMAP
    xor rdi, rdi
    mov rsi, r15
    mov rdx, PROT_READ
    mov r10, MAP_PRIVATE
    mov r8, r12
    xor r9, r9
    syscall
    js .useRead
    mov [mapAddr], rax

    mov rsi, rax
    mov rdx, r15
    call _feedBytes

    mov rax, SYS_MUNMAP
    mov rdi, [mapAddr]
    mov rsi, r15
    syscall
    jmp .close

.useRead:
    call _dumpReadLoop

.close:
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall
    jmp .out

.openFail:
    call _openError
    jmp .out

.dirFail:
    mov rsi, errIsDir
    mov rdx, errIsDirLen
    call _writeErr
    mov dword [exitStatus], EXIT_ERR
    jmp .out

.closeFail:
    push rax
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall
    pop rax
    call _openError

.out:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret
