//Added 'Vmodule.h' file by using HEADER_NAME_MODULE 
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#define INCLUDE_FILE(x) TOSTRING(x)
#include INCLUDE_FILE(HEADER_NAME_MODULE)

#include "verilated.h"
#include "verilated_fst_c.h"

VerilatedContext* contextp = NULL;
VerilatedFstC* tfp = NULL;

static MODULE_NAME* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedFstC;
  top = new MODULE_NAME;
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("waveform.fst");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
  delete tfp;
  delete contextp;
}

int main() {
	sim_init();
#if defined(MODULE_MUX_2X1_1BIT)
	top->sel=0; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a和b均初始化为“0”
                              top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，继续保持“0”，
  	            top->a=1; top->b=0;  step_and_dump_wave();   // 将a，b分别改为“1”和“0”，s的值不变，
                              top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，维持10个时间单位
	top->sel=1; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a，b分别变为“1,0,0”，维持10个时间单位
                              top->b=1;  step_and_dump_wave();
                    top->a=1; top->b=0;  step_and_dump_wave();
                              top->b=1;  step_and_dump_wave();  

#elif defined(MODULE_MUX_4X1_1BIT)
	top->sel=0b00; top->a=0b1110;  step_and_dump_wave();
                       top->a=0b0001;  step_and_dump_wave();
	top->sel=0b01; top->a=0b1110;  step_and_dump_wave();
                       top->a=0b0010;  step_and_dump_wave();
	top->sel=0b10; top->a=0b1010;  step_and_dump_wave();
                       top->a=0b0100;  step_and_dump_wave();
	top->sel=0b11; top->a=0b0111;  step_and_dump_wave();
                       top->a=0b1001;  step_and_dump_wave();

#elif defined(MODULE_ENCODER_4TO2_ONEHOT)
	top->en=0b0; top->a =0b0000; step_and_dump_wave();
                     top->a =0b0001; step_and_dump_wave();
                     top->a =0b0010; step_and_dump_wave();
                     top->a =0b0100; step_and_dump_wave();
                     top->a =0b1000; step_and_dump_wave();
	top->en=0b1; top->a =0b0000; step_and_dump_wave();
                     top->a =0b0001; step_and_dump_wave();
                     top->a =0b0010; step_and_dump_wave();
                     top->a =0b0100; step_and_dump_wave();
                     top->a =0b1000; step_and_dump_wave();

#elif defined(MODULE_ENCODER_4TO2_PRIORITY)
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

#elif defined(MODULE_DECODER_2TO4_ONEHOT)
	top->en = 0b0; top->a = 0b00;  step_and_dump_wave();
                       top->a = 0b01;  step_and_dump_wave();
                       top->a = 0b10;  step_and_dump_wave();
                       top->a = 0b11;  step_and_dump_wave();
	top->en = 0b1; top->a = 0b00;  step_and_dump_wave();
                       top->a = 0b01;  step_and_dump_wave();
                       top->a = 0b10;  step_and_dump_wave();
                       top->a = 0b11;  step_and_dump_wave();

#elif defined(MODULE_SWITCH)
	top->a = 0b0; top->b = 0b0; step_and_dump_wave();
        top->a = 0b0; top->b = 0b1; step_and_dump_wave();
        top->a = 0b1; top->b = 0b0; step_and_dump_wave();
        top->a = 0b1; top->b = 0b1; step_and_dump_wave();

#elif defined(MODULE_ALU)
	top->sel = 0b000; top->A = 0b1110; top->B = 0b1000; step_and_dump_wave();
			  top->A = 0b0110; top->B = 0b1100; step_and_dump_wave();
			  top->A = 0b1110; top->B = 0b1000; step_and_dump_wave();
















#endif
	sim_exit();
}
















