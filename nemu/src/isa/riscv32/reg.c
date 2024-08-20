/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include "local-include/reg.h"
#include <string.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
  for (int i = 0; i < 32; i++){
    printf("%s\t0x%08x\n", regs[i], cpu.gpr[i]); // Print each 32-bit register value in hexadecimal format
  }
  printf("pc\t0x%08x\n", cpu.pc); // Print the value of the program counter (PC)
}

word_t isa_reg_str2val(const char *s, bool *success) {
  // Check if the input string starts with $
  if (s[0] == '$') {
    s++; // Skip the $ symbol
  }

  // Traverse the regs[] array to find the matching register name
  for (int i = 0; i < 32; i++) {
    if (strcmp(s, regs[i]) == 0) {
      // If a match is found, return the corresponding register value
      *success = true;
      return cpu.gpr[i]; // cpu.gpr is the general-purpose register array
    }
  }

  // If no match is found, check if the string refers to the program counter (PC)
  if (strcmp(s, "pc") == 0) {
    *success = true;
    return cpu.pc; // Return the value of the program counter (PC)
  }

  // If no match is found at all, indicate failure
  *success = false;
  return 0; // Return a default error value
}

