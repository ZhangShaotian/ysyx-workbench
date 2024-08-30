#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "test-expr.h"
#include "common.h"

extern word_t expr(char *e, bool *success);

void test_expr(const char *filepath) {
  /* Open the input file */
  FILE *fp = fopen(filepath, "r");
  if (fp == NULL) {
    perror("Failed to open input file");
    return;
  }

  char *line = NULL;
  size_t len = 0;
  ssize_t read;
  int passed_tests = 0;    // Track number of passed tests
  int total_tests = 0;     // Track total number of tests

  while ((read = getline(&line, &len, fp)) != -1) {
    total_tests++;  // Increment total test count
    int expected_result;

    // Dynamically allocate memory for expr_str based on the line length
    char *expr_str = malloc(strlen(line) + 1);
    if (expr_str == NULL) {
      perror("Failed to allocate memory for expression string");
      free(line);
      fclose(fp);
      return;
    }

    // Parse the expected result and expression from the line
    if (sscanf(line, "%d %[^\n]", &expected_result, expr_str) == 2) {
      bool success = true;
      word_t result = expr(expr_str, &success);

      if (success) {
        printf("Expression: %s\n", expr_str);
        printf("Expected Result: %d, Evaluated Result: %d\n", expected_result, result);
        if (result == expected_result) {
          printf("Result matches!\n");
          passed_tests++;  // Increment passed test count
        } else {
          printf("Result does NOT match!\n");
          free(expr_str);
          break;  // Exit the loop and stop further checking
        }
      } else {
        printf("Failed to evaluate expression: %s\n", expr_str);
        free(expr_str);
        break;  // Exit the loop and stop further checking
      }
    } else {
      printf("Invalid line format: %s\n", line);
    }

    // Free the dynamically allocated memory for expr_str
    free(expr_str);
  }
  
  // Print the summary after all tests
  printf("Number of passed tests: %d\n", passed_tests);
  if (passed_tests < total_tests) {
    printf("There are failed tests.\n");  // Print if there are any failed tests
  }else if(passed_tests == total_tests){
    printf("There is no failed test.\n");  // Print if all tests passed
  }

  free(line);
  fclose(fp);
}

