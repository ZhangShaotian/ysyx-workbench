//Added 'Vtop_module.h' file by using HEADER_NAME 
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#define INCLUDE_FILE(x) TOSTRING(x)
#include INCLUDE_FILE(HEADER_NAME_TOP)

#include <nvboard.h>

static TOP_NAME dut;

void nvboard_bind_all_pins(TOP_NAME* top);

static void single_cycle() {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

static void reset(int n) {
  dut.rst = 1;
  while (n -- > 0) single_cycle();
  dut.rst = 0;
}

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();

  reset(10);

  while(1) {
    nvboard_update();
    single_cycle();
  }
}

