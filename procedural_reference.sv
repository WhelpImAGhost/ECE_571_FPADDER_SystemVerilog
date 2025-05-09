// module FPAdder (
//     input logic [31:0] A, B,
//     output logic [31:0] X
// );
    
module FPAdder (fpbus bus);

// Create a union for simple switch from
// bitwise to shortreal representation
typedef union {
	shortreal f;
	logic [31:0] bits;
} f_union;

// Create unions for A, B, and Result
f_union unionA, unionB, unionX;

// Add the two floats and return
// the bitwise representation
always_comb 
begin
	unionA.bits = bus.A;
	unionB.bits = bus.B;
	unionX.f = unionA.f + unionB.f;
	bus.Result = unionX.bits;
end
endmodule
