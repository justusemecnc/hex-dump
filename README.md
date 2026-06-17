# Hex Dump

x86-64 NASM hex dumper, `hexdump -C` style. Raw Linux syscalls only — no libc.

## What it does

- Canonical hex + ASCII output
- `-n length` to cap bytes, `-s offset` to skip ahead
- Multiple files, or stdin when none given
- mmap on big files (64 KiB+, no seek)
- Proper errors and exit codes (0 / 1 / 2)

## Requirements

- NASM, GNU `ld`, Linux x86-64 (or WSL)

## Build

```bash
make
./hexdump README.md
make clean
```

## Source

Assembly lives in `src/`.
