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

// This version supports negative sign '-' arithmetic, e.g. --1 = 1; 1+-1=0

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_NEQ,
  TK_NUM, TK_NEG, TK_HEX, TK_REG,
  TK_AND, TK_DEREF,
  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"==", TK_EQ},        // equal
  {"!=", TK_NEQ},       // not equal
  {"&&", TK_AND},       // logical AND
  {"0[xX][0-9a-fA-F]+", TK_HEX}, // hexadecimal number
  {"[0-9]+", TK_NUM},   // decimal number
  {"\\$\\$?[a-zA-Z0-9]+", TK_REG}, // register name
  {"\\-", '-'},         // minus or negative sign
  {"\\*", '*'},         // multiply or dereference
  {"/", '/'},           // divide
  {"\\(", '('},         // left parentheses
  {"\\)", ')'},         // right parentheses 
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/**
 * Initializes the regular expressions for tokenization.
 *
 * This function compiles the regex patterns defined in the `rules` array.
 * These compiled patterns are then used to match and identify different
 * components of the expression, such as operators, numbers, and parentheses.
 *
 * The function runs once at the beginning and stores the compiled regex
 * patterns in the `re` array for later use.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[30000000] __attribute__((used)) = {};// Modified the length of tokens[] from 32 to this new number
static int nr_token __attribute__((used))  = 0;

/**
 * Tokenizes the input expression into an array of tokens.
 *
 * This function scans through the input string `e` and matches it against
 * the compiled regex patterns stored in `re`. For each match, a token is
 * created and stored in the `tokens` array, which is then used for further
 * processing and evaluation of the expression.
 *
 * @param e The input expression string to be tokenized.
 * @return true if the tokenization is successful, false if an error occurs.
 */
static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

       /* Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);
        */
        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
          case TK_NOTYPE:
            // Skip spaces, do nothing
            break;
          case TK_NUM:
          case TK_HEX:
          case TK_REG:
          case '+':
          case '/':
          case '(':
          case ')':
          case TK_EQ:
          case TK_NEQ:
          case TK_AND:
            // Store the token
            tokens[nr_token].type = rules[i].token_type;
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            nr_token++;
            break;

          case '-':
            if (nr_token == 0 || tokens[nr_token - 1].type == '(' ||
                tokens[nr_token - 1].type == '+' || tokens[nr_token - 1].type == '-' ||
                tokens[nr_token - 1].type == '*' || tokens[nr_token - 1].type == '/' ||
                tokens[nr_token - 1].type == TK_NEG || tokens[nr_token - 1].type == TK_EQ ||
                tokens[nr_token - 1].type == TK_NEQ || tokens[nr_token - 1].type == TK_AND) {
              tokens[nr_token].type = TK_NEG; // Identify '-' as a negative sign
            } else {
              tokens[nr_token].type = '-'; // Identify '-' as a minus sign
            }
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            nr_token++;
            break;
          
          case '*':
            if (nr_token != 0 
                &&(tokens[nr_token - 1].type == TK_NUM || tokens[nr_token - 1].type == TK_HEX ||
                   tokens[nr_token - 1].type == TK_REG || tokens[nr_token - 1].type == ')')){
              tokens[nr_token].type = '*'; // Identify '*' as a multiply
            } else {
              tokens[nr_token].type = TK_DEREF; // Identify '*' as dereference
            }
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            nr_token++;
            break;


          default: 
            printf("Unknown token type: %d\n", rules[i].token_type);
            break;
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

// Check if the expression is surrounded by a matched pair of parentheses
bool check_parentheses(int p, int q){
  if (tokens[p].type == '(' && tokens[q].type == ')' ){
    int count = 0;
    for (int i = p + 1; i < q; i++){
      if (tokens[i].type == '(') count++;
      if (tokens[i].type == ')') count--;
      if (count < 0 ) return false;
    }
    return count == 0;
  }
  return false;
}

// Return the priority number of the operators to find_main_operator()
int get_operator_priority(int type) {
  switch (type) {
    case TK_AND: return -1;
    case TK_EQ:
    case TK_NEQ: return 0;
    case '+':
    case '-': return 1;
    case '*':
    case '/': return 2;
    case TK_DEREF:
    case TK_NEG: return 3;
    default: return 100;
  }
}

// Converts a token type integer to its corresponding string name to improve readability.
static const char* get_token_type_name(int type) {
    switch (type) {
        case TK_NOTYPE: return "TK_NOTYPE";
        case TK_EQ: return "TK_EQ";
        case TK_NEQ: return "TK_NEQ";
        case TK_NUM: return "TK_NUM";
        case TK_NEG: return "TK_NEG";
        case TK_HEX: return "TK_HEX";
        case TK_REG: return "TK_REG";
        case TK_AND: return "TK_AND";
        case TK_DEREF: return "TK_DEREF";
        case '+': return "PLUS";
        case '-': return "MINUS";
        case '*': return "MUL";
        case '/': return "DIV";
        case '(': return "LPAREN";
        case ')': return "RPAREN";
        default: return "UNKNOWN";
    }
}

// Return the operator position with the lowest priority
int find_main_operator(int p, int q) {
  int op = -1;
  int bracket_level = 0;
  int min_priority = 100;

  for (int i = p; i <= q; i++) {
    //Prints the token's index, type, and string to the terminal to improve the readability of the output.
    printf("Token %d: type = %s, str = '%s'\n", i, get_token_type_name(tokens[i].type), tokens[i].str);

    if (tokens[i].type == '(') bracket_level++;
    if (tokens[i].type == ')') bracket_level--;

    if (bracket_level == 0 && (tokens[i].type == '+' || tokens[i].type == '-' ||
                                tokens[i].type == '*' || tokens[i].type == '/' ||
                                tokens[i].type == TK_NEG || tokens[i].type == TK_EQ ||
                                tokens[i].type == TK_NEQ || tokens[i].type == TK_AND ||
                                tokens[i].type == TK_DEREF)) {
      // Ensure the first TK_NEG is always selected as the main operator in the expression like: ----1
      if(tokens[i].type == TK_NEG){ // Check if the operator has right operands for unary operators: negative sign
        if(i == p || tokens[i-1].type != TK_NEG){
          int priority = get_operator_priority(tokens[i].type);
          if (priority <= min_priority) {
            min_priority = priority;
            op = i;
          }
        }
        continue; // Skip further checks for TK_NEG
      }else if(tokens[i].type == TK_DEREF){ // Check if the operator has right operands for unary operators: dereference
        // Ensure it's a valid unary operator (e.g., it should not be at the end or misused)
        if (i == q) {
          printf("Error: Dereference operator '*' at position %d has no right operand.\n", i);
          return -1;  // Return immediately after detecting an error
        }
        int priority = get_operator_priority(tokens[i].type);
        if (priority <= min_priority) {
          min_priority = priority;
          op = i;
        }
        continue; // Skip further checks for TK_DEREF
      }else{ // Check if the operator has both left and right operands for binary operators
        if (i == p) {
          // If the operator is at the beginning, it is invalid
          printf("Error: Operator '%c' at position %d has no left operand.\n", tokens[i].type, i);
          return -1;  // Return immediately after detecting an error
        }
        if (i == q) {
          // If the operator is at the end, it is invalid
          printf("Error: Operator '%c' at position %d has no right operand.\n", tokens[i].type, i);
          return -1;  // Return immediately after detecting an error
        }
        if ((tokens[i-1].type != TK_NUM 
              && tokens[i-1].type != TK_HEX 
              && tokens[i-1].type != ')'
              && tokens[i-1].type != TK_REG) ||
            (tokens[i+1].type != TK_NUM 
             && tokens[i+1].type != TK_HEX 
             && tokens[i+1].type != '(' 
             && tokens[i+1].type != TK_NEG
             && tokens[i+1].type != TK_REG)) {
          // If the operator doesn't have valid operands on both sides, skip it
          printf("Error: Operator '%c' at position %d has invalid operands on one or both sides.\n", tokens[i].type, i);
          return -1;  // Return immediately after detecting an error
        }
      }

      int priority = get_operator_priority(tokens[i].type);
      if (priority <= min_priority) {
        min_priority = priority;
        op = i;
      }
    }
  }

  if (op == -1) {
    printf("No valid operator found in the expression.\n");
  }

  return op;
}

bool is_hex = false;

// Evaluate the value of the expression by Divide-and-Conquer Algorithm
word_t eval(int p, int q, bool *success){
  if (p > q) {
    printf("Error: position 'p'(leftmost) is larger than position 'q'(rightmost).\n");
    *success = false;
    return 0;
  }
  else if (p == q){
    if(tokens[p].type == TK_NUM){
      return (uint32_t)atoi(tokens[p].str);
    }else if(tokens[p].type == TK_HEX){
      is_hex = true; // Once a hexadecimal is found, is_hex stays true
      return (uint32_t)strtol(tokens[p].str, NULL, 16);
    }else if(tokens[p].type == TK_REG ){
      is_hex = true; // Once a register is found, is_hex stays true
      return isa_reg_str2val(tokens[p].str, success);
    }else{
      printf("Error: Single token is not a number.\n");
      *success = false;
      return 0;
    }
  }
  else if(check_parentheses(p,q) == true){
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p+1, q-1, success);
  }
  else{
    int op = find_main_operator(p, q);
    if (op == -1) {
      // Error messages are handled within find_main_operator(), no additional logging needed here
      *success = false;
      return 0;
    }
    
    /**
    * Handle unary minus (TK_NEG) by evaluating the expression to its right 
    * and negating the result. This ensures TK_NEG is treated as a unary operator 
    * rather than being mistakenly processed as a binary operator.
    */
    if (tokens[op].type == TK_NEG) {
      word_t val = eval(op + 1, q, success);
      return -val;
    }

    // Handle pointer dereference (TK_DEREF)
    if (tokens[op].type == TK_DEREF) {
      word_t val = eval(op + 1, q, success);
      if (*success) {
        return *(word_t *)(uintptr_t)val; // Dereference the pointer using uintptr_t
      } else {
        return 0;
      }
    }

    word_t val1 = eval(p, op - 1, success);
    word_t val2 = eval(op + 1, q, success);

    switch (tokens[op].type) {
      case '+': return val1 + val2;
      case '-': return val1 - val2;
      case '*': return val1 * val2;
      case '/': return (int32_t)val1 / (int32_t)val2;
      case TK_EQ: return val1 == val2;
      case TK_NEQ: return val1 != val2;
      case TK_AND: return val1 && val2;
      default: assert(0);
    }
  }
}

/**
 * Evaluates the given expression string.
 *
 * Tokenizes the input expression using `make_token()` and then evaluates
 * it with `eval()`, which recursively processes the tokens according to arithmetic rules.
 * If the expression is invalid, sets `success` to false.
 *
 * @param e The input expression string.
 * @param success Pointer to a boolean indicating evaluation success.
 * @return The result of the evaluated expression as a word_t.
 */
word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  is_hex = false;
  return eval(0, nr_token - 1, success);
} 

