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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

#define BUF_SIZE 65536

// this should be enough
static char buf[BUF_SIZE] = {};
static char code_buf[BUF_SIZE + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

// Function to append a random number (as a string) to the buffer
static void gen_num() {
  char num[4];
  unsigned int value;
  do {
    value = (rand() % 100); 
  } while (value == 0 && buf[strlen(buf) - 1] == '/'); 

  sprintf(num, "%u", value);
  strcat(buf, num);
}

// Function to append a character to the buffer
static void gen(char a){
  char str[2];
  str[0] = a;
  str[1] = '\0';
  strcat(buf, str);
}

// Function to append a random operator to the buffer
static void gen_rand_op(){
  char ops[] = "+-*/";
  char op = ops[rand() % 4]; // Randomly select one of the four operators
  gen(op);
}

// Function to return a random number less than n
static uint32_t choose(uint32_t n){
  return rand() % n;
}

// Function to generate a random expression
static void gen_rand_expr() {
  //buf[0] = '\0';
  switch (choose(3)){
    case 0: gen_num();
            break;
    case 1: gen('('); gen_rand_expr(); gen(')');
            break;
    default: 
            gen_rand_expr(); 
            gen_rand_op(); 
            if (buf[strlen(buf) - 1] == '/') {
              gen_num(); 
            } else {
              gen_rand_expr();
            }
            break;
  }
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    buf[0] = '\0';
    gen_rand_expr();

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc -O2 -MMD -Wall -Werror -Wno-overflow /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp); 

    printf("%u %s\n", result, buf);
    
    // Progress display: update progress on the same line
    fprintf(stderr, "\rProgress: %d/%d expressions generated", i + 1, loop);
  }
  
  // Print a newline at the end to move the cursor to the next line
  fprintf(stderr, "\n");

  return 0;
}
