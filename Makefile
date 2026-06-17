TARGET = hexdump
ASM    = main io parse format stream errors dump args data bss
OBJS   = $(ASM:%=src/%.o)

$(TARGET): $(OBJS)
	ld -nostdlib $(OBJS) -o $(TARGET)

src/%.o: src/%.asm src/const.inc
	nasm -f elf64 -I src/ $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: clean
