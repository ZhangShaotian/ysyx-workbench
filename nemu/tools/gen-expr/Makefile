#***************************************************************************************
# Copyright (c) 2014-2022 Zihao Yu, Nanjing University
#
# NEMU is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
#**************************************************************************************/

NAME = gen-expr
SRCS = gen-expr.c
include $(NEMU_HOME)/scripts/build.mk

# Define a new target that takes a number as an argument
.PHONY: generate

generate: $(BINARY)
	@$(BINARY) $(ARG) > $(BUILD_DIR)/input
	@echo "Generated expressions and saved to '$(BUILD_DIR)/input'"

# Only execute generate if a valid number is provided
run: $(BINARY)
	@if [ -z "$(n)" ]; then \
	    echo "Please provide a number using make run n=<number>"; \
	else \
	    $(MAKE) generate ARG=$(n); \
	fi
