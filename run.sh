#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

CC=clang
CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib"

OBJDUMP=llvm-objdump
OBJCOPY=llvm-objcopy

# シェルをビルド
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

# シェルのアセンブリをダンプ
$OBJDUMP -D shell.elf > shell.dump

# カーネルをビルド
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
            kernel.c common.c shell.bin.o

# カーネルのアセンブリをダンプ
$OBJDUMP -D kernel.elf > kernel.dump

# QEMUを起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
      -d unimp,guest_errors,int,cpu_reset -D qemu.log \
      -kernel kernel.elf
