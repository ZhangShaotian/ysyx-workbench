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
VERILATOR_CFLAGS += -MMD --build -cc  \
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

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "main_nvboard.cpp")
CSRCS += $(SRC_AUTO_BIND)

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

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

# check if MODULENAME is defined or not, if not, display an error message
check_modulename:
ifndef MODULENAME
	$(error MODULENAME is not defined. Please define MODULENAME, e.g., make MODULENAME=module sim)
endif

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
					 --Mdir $(OBJ_DIR)

include ../Makefile



#-------------------------------------------------------------
# Target List
# ----------------------------------------------------------
all: default

run: check_topname $(BIN)
	@$(BIN)

sim: check_modulename $(VSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(VERILATOR_SIM) $(VERILATOR_FLAGS_SIM) $(MAIN_MODULE) $(VSRCS)
	@echo "Simulation completed"
	@$(OBJ_DIR)/V$(MODULENAME)
	@gtkwave $(BUILD_DIR)/waveform.fst

clean:
	rm -rf $(BUILD_DIR)
.PHONY: default all clean check_topname run sim check_modulename
	


