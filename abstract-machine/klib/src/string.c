#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  panic("Not implemented");
}

char *strcpy(char *dst, const char *src) {
  char *ret = dst; // Save the original destination pointer to return later

  // Copy each character from src to dst, including the null terminator '\0'
  // The loop ends when the copied character is '\0' (assignment returns 0)
  while((*dst++ = *src++)){
    ; // Empty loop body; all work is done in the assignment above
  }

  return ret; // Return the original destination pointer
}

char *strncpy(char *dst, const char *src, size_t n) {
  panic("Not implemented");
}

char *strcat(char *dst, const char *src) {
  char *ret = dst; // Save the original starting address of dst to return later

  // Move dst pointer to the end of the current string (find '\0')
  while(*dst){
    dst++;
  }

  // Copy src (including the terminating '\0') to the end of dst
  while((*dst++ = *src++)){
    ; // Empty loop body: assignment returns the copied char; loop ends when '\0' is copied
  }

  return ret; // Return the original pointer to dst
}

int strcmp(const char *s1, const char *s2) {
  // Loop until the end of either string or a mismatch is found
  while(*s1 && (*s1 == *s2)){
    s1++;
    s2++;
  }

  // Compare as unsigned char to avoid negative values for chars > 127,
  // then return the difference as an int to preserve the sign.
  return (unsigned char)*s1 - (unsigned char)*s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  panic("Not implemented");
}

void *memset(void *s, int c, size_t n) {
  // Fill the first n bytes of the memory area pointed to by s
  // with the constant byte value c.
  // Parameters:
  //   s - pointer to the block of memory to fill
  //   c - value to be set. The value is passed as int, but it is converted to unsigned char
  //   n - number of bytes to be set to the value
  // Returns:
  //   The original pointer s

  unsigned char *p = (unsigned char *)s;  // Cast to unsigned char* for byte-by-byte access

  while (n--) {
    *p++ = (unsigned char)c; // Write one byte, then move to the next
  }

  return s; // Return the original pointer
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) {
  panic("Not implemented");
}

int memcmp(const void *s1, const void *s2, size_t n) {
    // Compare two memory blocks byte by byte.
  // Returns:
  //   0  if the first n bytes are equal
  //  <0  if the first differing byte in s1 is less than that in s2
  //  >0  if the first differing byte in s1 is greater than that in s2

  const unsigned char *p1 = (const unsigned char *)s1;
  const unsigned char *p2 = (const unsigned char *)s2;

  // If n == 0, the regions are considered equal
  while (n--) {
    if (*p1 != *p2) {
      // Cast to int to avoid unsigned wraparound; difference fits in int
      return (int)*p1 - (int)*p2;
    }
    ++p1;
    ++p2;
  }

  return 0;
}

#endif
