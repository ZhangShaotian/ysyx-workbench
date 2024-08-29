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

#ifndef __SDB_H__
#define __SDB_H__

#include <common.h>

word_t expr(char *e, bool *success);

// Definition of the watchpoint structure
typedef struct watchpoint {
  int NO;
  struct watchpoint *next;
  char *expr; // Dynamically allocated expression
  uint32_t last_value; // Last evaluated value of this expression
  /* TODO: Add more members if necessary */

} WP;

WP* new_wp(char *expr);   // Create a new watchpoint
void free_wp(int NO);     // Delete a watchpoint
WP* get_head();           // Get the head of the watchpoint list

// Function declarations
word_t expr(char *e, bool *success);
word_t vaddr_read(vaddr_t addr, int len);

#endif
