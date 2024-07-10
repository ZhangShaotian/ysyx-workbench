#include "verilated.h"
#include "verilated_fst_c.h"
#include "Vdecoder_2to4_onehot.h"

VerilatedContext* contextp = NULL;
VerilatedFstC* tfp = NULL;

static Vdecoder_2to4_onehot* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedFstC;
  top = new Vdecoder_2to4_onehot;
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

  top->en = 0b0;  top->a = 0b00;  step_and_dump_wave();
                  top->a = 0b01;  step_and_dump_wave();
                  top->a = 0b10;  step_and_dump_wave();
                  top->a = 0b11;  step_and_dump_wave();
  top->en = 0b1;  top->a = 0b00;  step_and_dump_wave();
                  top->a = 0b01;  step_and_dump_wave();
                  top->a = 0b10;  step_and_dump_wave();
                  top->a = 0b11;  step_and_dump_wave();
  sim_exit();
}
