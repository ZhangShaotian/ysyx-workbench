#####################################################
# npc/Makefile
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
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\"" -DHEADER_NAME="\"V$(TOPNAME).h\""

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

all: default

run: check_topname $(BIN)
	@$(BIN)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean check_topname run
