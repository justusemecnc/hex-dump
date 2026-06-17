; linux x86-64 syscalls we actually use
SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_OPEN    equ 2
SYS_CLOSE   equ 3
SYS_FSTAT   equ 5
SYS_LSEEK   equ 8
SYS_MMAP    equ 9
SYS_MUNMAP  equ 11
SYS_EXIT    equ 60

O_RDONLY    equ 0
SEEK_SET    equ 0
SEEK_END    equ 2
PROT_READ   equ 1
MAP_PRIVATE equ 2

; errno (positive — syscalls give you negative)
ENOENT      equ 2
EACCES      equ 13
EISDIR      equ 21

EXIT_OK     equ 0
EXIT_ERR    equ 1
EXIT_USAGE  equ 2

CHUNK_SIZE  equ 16
LINE_SIZE   equ 96
MMAP_THRESH equ 65536

; offsets into struct stat on x86-64 linux
STAT_MODE   equ 24
STAT_SIZE   equ 48
S_IFMT      equ 0o170000
S_IFDIR     equ 0o040000
