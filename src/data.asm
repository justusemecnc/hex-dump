default rel
%include "const.inc"

section .data
global hexDigits, sep2, pipeOpen, pipeClose
global errNotFound, errNotFoundLen, errPerm, errPermLen
global errIsDir, errIsDirLen, errOpen, errOpenLen
global errBadArg, errBadArgLen

    hexDigits   db "0123456789abcdef"

    errNotFound db "Error: File not found", 10
    errNotFoundLen equ $ - errNotFound
    errPerm     db "Error: Permission denied", 10
    errPermLen  equ $ - errPerm
    errIsDir    db "Error: Is a directory", 10
    errIsDirLen equ $ - errIsDir
    errOpen     db "Error: Cannot open file", 10
    errOpenLen  equ $ - errOpen
    errBadArg   db "Error: Invalid argument", 10
    errBadArgLen equ $ - errBadArg

    sep2        dw "  "
    pipeOpen    dw " |"
    pipeClose   db "|", 10
