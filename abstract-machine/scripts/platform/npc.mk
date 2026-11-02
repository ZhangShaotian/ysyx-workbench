AM_SRCS := riscv/npc/start.S \
           riscv/npc/trm.c \
           riscv/npc/ioe.c \
           riscv/npc/timer.c \
           riscv/npc/input.c \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
						 --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
.PHONY: $(AM_HOME)/am/src/riscv/npc/trm.c

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

# This NPC currently implements the eight-instruction minirv subset.
ifeq ($(ARCH),minirv-npc)
NPC_HOME ?= $(abspath $(AM_HOME)/../npc)
MODULENAME ?= ysyx_v3_TopProc_minirv
CYCLES ?= 1000000
WAVE ?= 0
run: image
	python3 $(NPC_HOME)/scripts/run_am.py --bin $(IMAGE).bin --elf $(IMAGE).elf \
		--nm $(CROSS_COMPILE)nm --module $(MODULENAME) --cycles $(CYCLES) --wave $(WAVE)
endif
