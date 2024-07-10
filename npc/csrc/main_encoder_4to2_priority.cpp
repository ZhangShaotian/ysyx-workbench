#include "verilated.h"
#include "verilated_fst_c.h"
#include "Vencoder_4to2_priority.h"

VerilatedContext* contextp = NULL;
VerilatedFstC* tfp = NULL;

static Vencoder_4to2_priority* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedFstC;
  top = new Vencoder_4to2_priority;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("waveform.fst");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();

  top->en=0b0; top->a =0b0000; step_and_dump_wave();
               top->a =0b0001; step_and_dump_wave();
               top->a =0b0011; step_and_dump_wave();
               top->a =0b0111; step_and_dump_wave();
               top->a =0b1111; step_and_dump_wave();
  top->en=0b1; top->a =0b0000; step_and_dump_wave();
               top->a =0b0001; step_and_dump_wave();
               top->a =0b0011; step_and_dump_wave();
               top->a =0b0111; step_and_dump_wave();
               top->a =0b1111; step_and_dump_wave();
  sim_exit();
}
