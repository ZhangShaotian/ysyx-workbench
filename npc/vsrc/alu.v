//=========================================================
//A parameterized n-bit ALU with overflow, zero, and carry flags, supporting 
//addition, subtraction, bitwise logic, and comparison operations.
//==========================================================
module alu
#(
        parameter nbit = 4 
)
(
        input signed [nbit-1:0] A,
        input signed [nbit-1:0] B,
        input [2:0] sel,
        output reg [nbit-1:0] result,
        output reg overflow,
        output reg zero,
        output reg carry
);
        always@(*) begin
                //default value:
                result = 0;  
                overflow = 0;
                zero = 0;
                carry = 0;
                case (sel)
                3'b000: begin           // A+B
                        {carry, result} = A + B;
                        overflow = (A[nbit-1]==B[nbit-1]) && (result[nbit-1]!=A[nbit-1]);
                        zero = ~(|result);
                end 
                3'b001: begin           // A-B
                        {carry, result} = A -B; 
                        overflow = (A[nbit-1] != B[nbit-1]) && (result[nbit-1] !=A[nbit-1]);
                        zero = ~(|result);
                end 
                3'b010: begin           //NOT A
                        result = ~ A;
                        zero = ~(|result);
                end 
                3'b011: begin           //A and B
                        result = A & B;
                        zero = ~(|result);
                end 
                3'b100: begin           //A or B
                        result = A | B;
                        zero = ~(|result);
                end 
                3'b101: begin           //A xor B
                        result = A ^ B;
                        zero = ~(|result);
                end 
                3'b110: begin           //If A<B then out=1; else out=0;
                        result = {(nbit-1){1'b0}, (A < B)}; 
                        zero = ~(|result);
                end 
                3'b111: begin           //If A==B then out=1; else out=0;
                        result = {(nbit-1){1'b0}, (A == B)};
                        zero = ~(|result);
                end 
                default: begin
                        result = 0;  
                        overflow = 0;
                        zero = 0;
                        carry = 0;
                end 
                endcase
        end 
endmodule

