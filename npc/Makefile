# ===============================================================
# npc/Makefile
# ===============================================================
# usage:
# 	make / make all: At this moment, it is used to run one top module connected to NVBoard, not all of them
#
# 	make TOPNAME=XXXXX run: To execute the top module specified in TOPNAME
#
# 	make clean: Remove all temporary files
#
# 	make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_addi_jalr_lui.hex sim
# 	Append WAVE=0 to run without opening GTKWave.
#
# Environment Variables:
# 	TOPNAME: Arguments to select the correct verilog top_module in npc/vsrc/ folder
# 	e.g. make TOPNAME=top_switch run

# -------------------------------------------------------------
# This part is used for connecting top module to the NVBoard
# -------------------------------------------------------------
TOPNAME ?=
NXDC_FILES = constr/$(TOPNAME).nxdc
INC_PATH ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -sv --timescale 1ns/1ps \
				-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: check_topname $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source (NVBoard target: all files)
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
CSRCS = $(shell find $(abspath ./csrc) -name "main_nvboard.cpp")

# ---------------------------------------------------------------------------
# Per-version source directories for the `sim` target.
# Each processor version lives in its own self-contained subdirectory so that
# modules with identical names across versions never appear in the same
# compilation unit.  Add one entry per version here.
# ---------------------------------------------------------------------------
NPC_VSRC_BASE := vsrc/ysyx_24080034_npc
SIM_SRCDIR_ysyx_v1_TopProcAddi        := $(NPC_VSRC_BASE)/v1_proc_addi
SIM_SRCDIR_ysyx_v2_TopProc_Addi_Jalr  := $(NPC_VSRC_BASE)/v2_proc_addi_jalr
SIM_SRCDIR_ysyx_v3_TopProc_minirv     := $(NPC_VSRC_BASE)/v3_proc_minirv

SIM_DEFAULT_HEX_ysyx_v1_TopProcAddi       := hex/program_ebreak.hex
SIM_DEFAULT_HEX_ysyx_v2_TopProc_Addi_Jalr := hex/program_addi_jalr_lui.hex
SIM_DEFAULT_HEX_ysyx_v3_TopProc_minirv    := hex/program_addi_jalr_lui.hex

_SIM_SRCDIR = $(SIM_SRCDIR_$(MODULENAME))
VSRCS_SIM   = $(shell find $(abspath $(_SIM_SRCDIR)) -name "*.v" -o -name "*.sv")
CSRCS += $(SRC_AUTO_BIND)

# Pure RTL simulation and cleanup do not depend on NVBoard.
# With no explicit goal, make builds the default NVBoard target.
ifneq ($(strip $(filter-out sim clean check_modulename check_hex,$(if $(MAKECMDGOALS),$(MAKECMDGOALS),default))),)
# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk
endif

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\"" -DHEADER_NAME_TOP="\"V$(TOPNAME).h\""

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

# check if TOPNAME is defined or not, if not, display an error message
check_topname:
ifndef TOPNAME
	$(error TOPNAME is not defined. Please define TOPNAME, e.g., make TOPNAME=top_module run)
endif



# -------------------------------------------------
# This part is used for verilog module simulations
# ------------------------------------------------

MODULENAME ?=
HEX ?= $(SIM_DEFAULT_HEX_$(MODULENAME))
SIM_BUILD_DIR = $(BUILD_DIR)/$(MODULENAME)
SIM_OBJ_DIR = $(SIM_BUILD_DIR)/obj_dir
SIM_WAVE_FILE = $(SIM_BUILD_DIR)/waveform.fst
WAVE ?= 1
BASE ?= auto
CYCLES ?= auto
HALT ?= auto
# Keep runtime image paths as one shell argument, including spaces/quotes.
shell_quote = '$(subst ','"'"',$(1))'

# check if MODULENAME is defined or not, if not, display an error message
check_modulename:
ifndef MODULENAME
	$(error MODULENAME is not defined. Please define MODULENAME, e.g., make MODULENAME=module sim)
endif
ifeq ($(strip $(_SIM_SRCDIR)),)
	$(error Unknown MODULENAME '$(MODULENAME)'. Register its source directory with SIM_SRCDIR_$(MODULENAME))
endif

check_hex:
	@test -n $(call shell_quote,$(HEX)) || { echo "HEX is empty. Use HEX=hex/program_ebreak.hex" >&2; exit 1; }
	@test -f $(call shell_quote,$(HEX)) && test -r $(call shell_quote,$(HEX)) || { echo "HEX must name a readable file:" $(call shell_quote,$(HEX)) >&2; exit 1; }

# Define the path for necessary files
MAIN_MODULE_DIR := ./csrc
MODULE_DIR := ./vsrc

# Define source files
MAIN_MODULE := $(abspath $(MAIN_MODULE_DIR)/main_sim.cpp)

# Automatically determine the module define being used in /csrc/main_sim.cpp
MODULE_DEFINE := -DMODULE_$(shell echo $(MODULENAME) | tr '[:lower:]' '[:upper:]')



# Define Verilator command and symbol
VERILATOR_SIM := verilator
VERILATOR_FLAGS_SIM := --trace-fst --cc --exe --build -j 0 -Wall --top-module $(MODULENAME) \
		       --Wno-DECLFILENAME \
		       --CFLAGS -DMODULE_NAME="\"V$(MODULENAME)\"" \
                       --CFLAGS -DHEADER_NAME_MODULE="\"V$(MODULENAME).h\"" \
		       --CFLAGS "$(MODULE_DEFINE)" \
		       --Mdir $(SIM_OBJ_DIR)

# The course's Git tracer derives YSYX_HOME from NEMU_HOME, including in
# recursive make invocations. Supply the sibling directory when unset.
export NEMU_HOME := $(if $(strip $(NEMU_HOME)),$(NEMU_HOME),$(abspath ../nemu))

include ../Makefile



#-------------------------------------------------------------
# Target List
# ----------------------------------------------------------
all: default

run: check_topname $(BIN)
	@$(BIN)

# Use the course tracer's identity for automatic snapshots only; leave the
# user's repository/global Git identity untouched.
sim: export GIT_COMMITTER_NAME = $(TRACER)
sim: export GIT_COMMITTER_EMAIL = tracer@ysyx.org
sim: check_modulename check_hex
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@mkdir -p $(SIM_BUILD_DIR)
	$(VERILATOR_SIM) $(VERILATOR_FLAGS_SIM) $(MAIN_MODULE) $(VSRCS_SIM)
	@echo "Running $(MODULENAME), HEX:" $(call shell_quote,$(HEX))
	@python3 scripts/run_image.py --module $(MODULENAME) --hex $(call shell_quote,$(HEX)) \
		--wave "$(SIM_WAVE_FILE)" --binary "$(SIM_OBJ_DIR)/V$(MODULENAME)" \
		--base $(call shell_quote,$(BASE)) --cycles $(call shell_quote,$(CYCLES)) --halt $(call shell_quote,$(HALT))
	@echo "Simulation completed: $(MODULENAME), waveform: $(SIM_WAVE_FILE)"
	@if [ "$(WAVE)" = "1" ]; then gtkwave $(SIM_WAVE_FILE); fi

clean:
	rm -rf $(BUILD_DIR)
.PHONY: default all clean check_topname run sim check_modulename check_hex
	


