#include "verilated.h"
#include "verilated_fst_c.h"
#include "Vmux_4x1_1bit.h"

VerilatedContext* contextp = NULL;
VerilatedFstC* tfp = NULL;

static Vmux_4x1_1bit* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedFstC;
  top = new Vmux_4x1_1bit;
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("waveform.fst");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();
  top->sel=0b00;  top->a=0b1110;  step_and_dump_wave();
                top->a=0b0001;  step_and_dump_wave();
  top->sel=0b01;  top->a=0b1110;  step_and_dump_wave();
                top->a=0b0010;  step_and_dump_wave();
  top->sel=0b10;  top->a=0b1010;  step_and_dump_wave();
                top->a=0b0100;  step_and_dump_wave();
  top->sel=0b11;  top->a=0b0111;  step_and_dump_wave();
                top->a=0b1001;  step_and_dump_wave();
  sim_exit();
}
