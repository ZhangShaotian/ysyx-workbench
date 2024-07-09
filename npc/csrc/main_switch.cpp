#include <Vswitch.h>
#include <verilated.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <verilated_fst_c.h>

  int main(int argc, char** argv) {
      VerilatedContext* contextp = new VerilatedContext;
      contextp->commandArgs(argc, argv);
      Vswitch* mySwitch = new Vswitch{contextp};

      //Enable trace
      VerilatedFstC *tfp = new VerilatedFstC;
      contextp->traceEverOn(true);
      mySwitch->trace(tfp, 99);
      tfp->open("waveform.fst");

      while (!contextp->gotFinish() && contextp->time() < 500) { 
              int a = rand() & 1;
              int b = rand() & 1;
              mySwitch -> a = a;
              mySwitch -> b = b;
              mySwitch -> eval(); 
              printf("a = %d, b = %d, f = %d\n", a, b, mySwitch->f);
              //Dump waveform data
              tfp->dump(contextp->time());
              assert(mySwitch->f == (a ^ b));


              //Increment time
              contextp->timeInc(1);
      }
      delete mySwitch;
      delete contextp;
      tfp -> close();
      delete tfp;
      return 0;
  }
