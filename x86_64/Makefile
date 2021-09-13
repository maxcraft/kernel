.PHONY: all crean

NASM ?= nasm
NASFLAGS += -f elf64

%.o: %.asm
	$(NASM) $(NASFLAGS) -o $@ $<

ASM_SRC := $(shell find . -name *.asm)
C_SRC := $(shell find . -name *.c)
OBJS := $(ASM_SRC:.asm=.o) $(C_SRC:.c=.o)
BIN := kernel.bin
ISO := kernel.iso
#CFLAGS +=

all: $(ISO) linker/linker.ld

boot/entry.o boot/mb2_header.o : boot/mb2.inc

$(ISO): $(BIN)
	cp $(BIN) iso/boot/
	# grub-mkrescue /usr/lib/grub/i386-pc -o kernel.iso iso
	grub-mkrescue /usr/lib/grub/x86_64-efi -o kernel.iso iso

kernel.bin: $(OBJS)
	$(LD) -n -o $@ -T linker/linker.ld $^

clean:
	$(RM) $(BIN) $(OBJS) kernel.iso iso/boot/kernel.bin
