static void * alpha_benchmark(void * args) {
  asm volatile("top:    ; \
                jmp top ");
  return NULL;
}
