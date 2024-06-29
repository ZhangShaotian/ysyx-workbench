all:
	@echo "Write this Makefile by your self."

# Define the path for necessary files
MAIN_SWITCH_DIR := ./csrc
SWITCH_DIR := ./vsrc

# Define source files
MAIN_SWITCH := $(MAIN_SWITCH_DIR)/main_switch.cpp
SWITCH := $(SWITCH_DIR)/switch.v

# Define Verilator command and symbol
VERILATOR := verilator
VERILATOR_FLAGS := --trace --cc --exe --build -j 0 -Wall
TARGET := sim

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(VERILATOR) $(VERILATOR_FLAGS) $(MAIN_SWITCH) $(SWITCH)
	@echo "Simulation completed"

include ../Makefile

clean:
	rm -rf ./obj_dir
	rm -f waveform.vcd

.PHONY: clean all sim
