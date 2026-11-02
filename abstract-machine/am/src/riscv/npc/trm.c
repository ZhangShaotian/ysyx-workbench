#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#ifdef __ISA_MINIRV__
#define PMEM_SIZE (512 * 1024)  // Match the v3 NPC data RAM.
#else
#define PMEM_SIZE (128 * 1024 * 1024)
#endif
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
}

__attribute__((noinline)) void halt(int code) {
  // Keep the exit status live in the ABI argument register at EBREAK.
  register int a0 asm("a0") = code;
  asm volatile("ebreak" : : "r"(a0) : "memory");
  while (1);
}

void _trm_init() {
  int ret = main(mainargs);
  halt(ret);
}
