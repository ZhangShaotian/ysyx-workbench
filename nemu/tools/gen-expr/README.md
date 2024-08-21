# Gen-Expr Tool

This tool, `gen-expr`, is designed to generate random arithmetic expressions and evaluate their results. The generated expressions can be used for testing purposes, especially in environments where you need to validate expression evaluation.

## Source Files

### `gen-expr.c`

This C program generates random arithmetic expressions using a recursive approach. The main functions in the program are:

- **`gen_num()`**: Appends a random number to the expression buffer.
- **`gen(char a)`**: Appends a single character to the expression buffer.
- **`gen_rand_op()`**: Appends a random operator (`+`, `-`, `*`, `/`) to the expression buffer.
- **`gen_rand_expr()`**: Recursively generates a random expression by combining numbers, operators, and parentheses.
- **`main()`**: The entry point of the program. It handles command-line arguments, loops through the expression generation process, compiles the generated code, and then executes it to obtain the result.

### `Makefile`

The `Makefile` is used to compile and run the `gen-expr` program. It includes various targets to automate the build process.

#### Key Targets

- **`run`**: This is the main target to run the tool. It accepts an argument `n=<number>` to specify how many random expressions to generate. The expressions and their results will be printed to the console.

- **`generate`**: This target generates the expressions and saves them to a file (`$(BUILD_DIR)/input`). It is internally invoked by the `run` target.

## Usage

To use the tool, you must specify the number of expressions to generate by running the following command:

```bash
make run n=<number>

