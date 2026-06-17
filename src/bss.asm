default rel
%include "const.inc"

section .bss
global readBuf, lineBuf, statBuf, carryBuf
global seekVal, limitVal, limitSet, exitStatus, mapAddr
global streamOffset, didDump, streamInit, skipRemaining
global bytesLeft, carryCount

    readBuf       resb CHUNK_SIZE
    lineBuf       resb LINE_SIZE
    statBuf       resb 144

    seekVal       resq 1
    limitVal      resq 1
    limitSet      resb 1
    exitStatus    resd 1
    mapAddr       resq 1
    streamOffset  resq 1
    didDump       resb 1
    streamInit    resb 1
    skipRemaining resq 1
    bytesLeft     resq 1
    carryCount    resq 1
    carryBuf      resb CHUNK_SIZE
