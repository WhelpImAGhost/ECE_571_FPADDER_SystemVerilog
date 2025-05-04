module FPAdder (
    input logic [31:0] A, B,
    output logic [31:0] X
);
    

typedef union {
	shortreal f;
	logic [31:0] bits;
} f_union;

f_union unionA, unionB, unionX;

always_comb 
begin
	unionA.bits = A;
	unionB.bits = B;
	unionX.f = unionA.f + unionB.f;
	X = unionX.bits;
end
endmodule
