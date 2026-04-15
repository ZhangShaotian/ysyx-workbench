#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);  
    // Initialize a 'va_list' to retrieve variable arguments.
    // The second parameter 'fmt' tells va_start where the fixed arguments end
    // so that the following arguments can be accessed one-by-one by va_arg.

    char *p = out;  
    // Output pointer, used to write generated characters into the buffer.

    while (*fmt) {  
        // Iterate through each character of the format string.
        if (*fmt == '%' && (*(fmt + 1) == 's' || *(fmt + 1) == 'd')) {
            fmt++;  // Skip '%' and move to the format specifier.

            if (*fmt == 's') {
                // Handle %s : fetch a 'char*' from variable arguments.
                char *str = va_arg(args, char *);
                // 'va_arg' retrieves the next argument from the va_list.
                // For %s the expected type is 'char *'.

                // Copy the entire string until its null terminator.
                while (*str)
                    *p++ = *str++;

            } else if (*fmt == 'd') {
                // Handle %d : fetch an integer.
                int num = va_arg(args, int);

                // Convert integer to decimal string (simple implementation).
                char buf[20];  
                // Temporary buffer for reversed digits.
                int i = 0;
                int neg = 0;

                if (num < 0) {
                    // If negative, remember the sign and convert to positive.
                    neg = 1;
                    num = -num;
                }

                // Convert digits to characters in reverse order.
                // Example: 123 -> '3','2','1'
                do {
                    buf[i++] = (num % 10) + '0';
                    num /= 10;
                } while (num > 0);

                if (neg)
                    buf[i++] = '-';  
                // Add negative sign at the end (still reversed).

                // Reverse the characters back when writing into output.
                while (i-- > 0)
                    *p++ = buf[i];
            }

        } else {
            // Normal character: copy directly to output buffer.
            *p++ = *fmt;
        }

        fmt++;  // Move to next character in the format string.
    }

    *p = '\0';  // Null-terminate the output buffer.

    va_end(args);
    // Clean up the va_list. (Not strictly needed on many platforms but required by C standard.)

    return p - out;  
    // Return the number of characters written (excluding the null terminator).
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
