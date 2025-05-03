module FPAdder (
    input logic [31:0] A, B,
    output logic [31:0] X
);
    
shortreal floatA, floatB, floatX;

always_comb 
begin

    floatA = A;                 // Convert A to float
    floatB = B;                 // Convert B to float
    floatX = flaotA + floatB;   // Add the two floats
    X = floatX;                 // Implicit cast X to bits
end
endmodule