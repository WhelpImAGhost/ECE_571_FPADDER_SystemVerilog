module top;

shortreal floatA, floatB, floatX;
int error, tests;
bit [31:0] rawA, rawB;


fpbus bus();
Mask mask(bus.mask);
Alignment align(bus.align);
ALU alu(bus.alu);
Normalize N1(bus.normal);

// Create a union to easily switch between 
// bit representation and shortreal representation
typedef union {
       	shortreal f;
        logic [31:0] bits;
} f_union;

// Create unions for A, B, and X
f_union unionA, unionB, unionX;

initial
begin 

    // Assign inputs and outputs to bitwise unions
    unionA.f = -1.245;
	unionB.f = 2.753;
    #10;
    unionX.f = unionA.f + unionB.f;
    bus.A = unionA.bits;
    bus.B = unionB.bits;
    #10;

    `ifdef DEBUGTB
        $display("A: %h, B: %h", unionA.bits, unionB.bits);
    `endif

    if (bus.normalizedExponent !== unionX.bits[30:23])
    begin
        error++;
        $display("Expected Normalized Exponent: %h, but Received: %h",
        unionX.bits[30:23], bus.normalizedExponent);
    end
    if(bus.normalizedMantissa !== unionX.bits[22:0])
    begin
        error++;
        $display("Expected Normalized Mantissa: %h, but Received: %h",
        unionX.bits[22:0], bus.normalizedMantissa);
    end
    if(bus.normalizedSign !== unionX.bits[31])
    begin
        error++;
        $display("Expected Normalized Sign: %h, but Received: %h",
        unionX.bits[31], bus.normalizedSign);
    end

    if (error == 0) $display("FP Adder passed static case. Test Passed");
    else            $display("FP Adder failed static case. Test Failed");
    $display("Total Errors: %d", error);

    $finish;
end
endmodule
