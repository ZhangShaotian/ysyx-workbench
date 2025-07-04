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

#include "sdb.h"

#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */
WP* new_wp(char *expression){
  if(free_ == NULL){
    assert(0 && "No free watchpoints available!");
  }

  WP *wp = free_;
  free_ = free_->next;

  wp->next = head;
  head = wp;

  wp->expr = strdup(expression);
  assert(wp->expr != NULL && "Failed to allocate memory for expression!");

  bool success = true;
  wp->last_value = expr(wp->expr, &success);
  assert(success && "Failed to evaluate expression when setting watchpoint!");

  return wp;
}

void free_wp(int NO){
  WP *prev = NULL;
  WP *wp = head;
  while(wp != NULL){
    if(wp->NO == NO){
      if(prev != NULL){
        prev->next = wp->next;
      }else{
        head = wp->next;
      }
      free(wp->expr);
      wp->expr = NULL;

      wp->next = free_;
      free_ = wp;
      
      // Print a message indicating the watchpoint has been deleted
      printf("Watchpoint %d deleted.\n", NO);

      return;
    }
 
    prev = wp;
    wp = wp->next;
  }
  printf("No watchpoint with number %d found.\n", NO);
}
      
// Function to get the head of the watchpoint list
WP* get_head() {
    return head;
}    
  


