#include "verilated.h"
#include "verilated_fst_c.h"
#include "Vmux_2x1_1bit.h"

VerilatedContext* contextp = NULL;
VerilatedFstC* tfp = NULL;

static Vmux_2x1_1bit* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedFstC;
  top = new Vmux_2x1_1bit;
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("mux_2x1_1bit_dump.fst");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();

  top->sel=0; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a和b均初始化为“0”
                        top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，继续保持“0”，
              top->a=1; top->b=0;  step_and_dump_wave();   // 将a，b分别改为“1”和“0”，s的值不变，
                        top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，维持10个时间单位
  top->sel=1; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a，b分别变为“1,0,0”，维持10个时间单位
                        top->b=1;  step_and_dump_wave();
              top->a=1; top->b=0;  step_and_dump_wave();
                        top->b=1;  step_and_dump_wave();

  sim_exit();
}
