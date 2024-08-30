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
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
  nemu_state.state = NEMU_QUIT; // Set the NEMU state to quit, indicating the program should terminate
  return -1;  // Return -1 to indicate the command processed successfully and triggered a quit operation from sdb_mainloop()
}

static int cmd_help(char *args);

static int cmd_si(char *args){
  int n = 1; // Defaulting to executing 1 instruction

  if (args != NULL) {
    char *endptr;
    n = strtol(args, &endptr, 10); // Convert the argument to an integer and check for errors

    // Check if there are any non-space characters after the first number
    if (*endptr != '\0') {
      while (*endptr == ' ') endptr++; // Skip any spaces

      if (*endptr != '\0') { // If there's anything left that's not a space, it's an error
        printf("Error: Invalid argument '%s'. Only one integer is allowed.\n", args);
        return 0; // Return without executing any instruction
      }
    }

    if (n <= 0) {
      printf("Error: The argument '%s' is not a positive integer.\n", args);
      return 0; // Return without executing any instruction
    }
  }

  cpu_exec(n); // Execute n instruction
  return 0;
}

static int cmd_info(char *args) {
  if (args == NULL) {
    printf("Error: No subcommand provided. Use 'info r' or 'info w'.\n");
    return 0;
  }

  if (strcmp(args, "r") == 0) {
    isa_reg_display(); // Call function to print register state
  } else if (strcmp(args, "w") == 0) {
    WP *wp = get_head();  // Use get_head() to access the static head variable in watchpoint.c
    while (wp != NULL) {
      printf("Watchpoint %d: %s = %u\n", wp->NO, wp->expr, wp->last_value);
      wp = wp->next;
    }
  } else {
    printf("Error: Unknown subcommand '%s'.\n", args);
  }

  return 0;
}

static int cmd_x(char *args) {
  if (args == NULL) {
    printf("Error: No arguments provided. Usage: x N EXPR\n");
    return 0;
  }

  // Parse input arguments to get N and EXPR
  char *n_str = strtok(args, " ");
  char *expr_str = strtok(NULL, " ");

  if (n_str == NULL || expr_str == NULL) {
    printf("Error: Invalid arguments. Usage: x N EXPR\n");
    return 0;
  }

  // Convert N from string to integer
  int n = atoi(n_str);
  if (n <= 0) {
    printf("Error: The number of memory units to read 'N' must be positive.\n");
    return 0;
  }

  // Evaluate the expression to get the starting address
  bool success = true;
  word_t start_addr = expr(expr_str, &success);
  if (!success) {
    printf("Error: Failed to evaluate expression '%s'.\n", expr_str);
    return 0;
  }

  // Read N memory units (4 bytes each) starting from the calculated address and print them in hexadecimal format
  for (int i = 0; i < n; i++) {
    word_t data = vaddr_read(start_addr + i * 4, 4);
    printf("Memory[%#x]: %#x\n", start_addr + i * 4, data);
  }

  return 0;
}

extern bool is_hex;

static int cmd_expr(char *args){
  bool success = true;
  word_t temp_result = expr(args, &success);
  int32_t result = (int32_t) temp_result;

  if (success) {
    if (is_hex) {
      printf("Result in hexadecimal format: %#x\n", result); // Use %#x format for hexadecimal output
    } else {
      printf("Result in decimal format: %d\n", result);  // Use %d format for decimal output
    }
  }

  return 0;
}

static int cmd_watch(char *args){
  WP *wp = new_wp(args);
  printf("Watchpoint %d set for expression: %s\n", wp->NO, wp->expr);
  return 0;
}

static int cmd_delete(char *args){
  int NO = atoi(args);
  free_wp(NO);  
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Execute one or N instructions step by step. Example: 'si' or 'si 10'", cmd_si },
  { "info", "Display program status. Example: 'info r' or 'info w'", cmd_info },
  { "p", "Evaluate the value of an expression. Example: 'p $eax + 1'", cmd_expr },
  { "w", "Set a watchpoint. Example: 'w *0x80000000'", cmd_watch },
  { "d", "Delete a watchpoint by number. Example: 'd 2'", cmd_delete },
  { "x", "Scan memory. Usage: 'x N EXPR'. Example: 'x 10 $esp'", cmd_x },
  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
