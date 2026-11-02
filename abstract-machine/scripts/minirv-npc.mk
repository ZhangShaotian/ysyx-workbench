include $(AM_HOME)/scripts/isa/riscv.mk
include $(AM_HOME)/scripts/platform/npc.mk

export PATH := $(PATH):$(abspath $(AM_HOME)/tools/minirv)
CC = $(AM_HOME)/tools/minirv/minirv-gcc
AS = $(AM_HOME)/tools/minirv/minirv-gcc
CXX = $(AM_HOME)/tools/minirv/minirv-g++

COMMON_CFLAGS += -march=rv32e_zicsr -mabi=ilp32e  # overwrite
# Use GCC's builtin headers without requiring a 32-bit hosted libc.
# GCC limits.h otherwise includes glibc's limits.h even in freestanding mode.
CFLAGS       += -ffreestanding -D_LIBC_LIMITS_H_
LDFLAGS       += -melf32lriscv                    # overwrite

AM_SRCS += riscv/npc/libgcc/div.S \
           riscv/npc/libgcc/muldi3.S \
           riscv/npc/libgcc/multi3.c \
           riscv/npc/libgcc/ashldi3.c \
           riscv/npc/libgcc/unused.c
