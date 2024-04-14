#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

# clangのパス (Ubuntuの場合は CC=clang)
CC=clang
CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib"

# ダンプコマンド
OBJDUMP=llvm-objdump

# カーネルをビルド
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c

# カーネルのアセンブリをダンプ
$OBJDUMP -D kernel.elf > kernel.dump

# QEMUを起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
      -d unimp,guest_errors,int,cpu_reset -D qemu.log \
      -kernel kernel.elf
