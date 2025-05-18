module top;

    int error, tests;
    shortreal fA, fB, fX;
    bit [31:0] rawA, rawB, iA, iB, iX, iEx;


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

always_comb begin
	iA = $shortrealtobits(fA);
	iB = $shortrealtobits(fB);
	iX = bus.Result;
	iEx = $shortrealtobits(fA + fB);
    bus.A = iA;
    bus.B = iB;
    fX = $bitstoshortreal(iX);
end

    initial
    begin 

        // Assign inputs and outputs to bitwise unions
        fA = -1.245;
        fB = 2.753;

        #10

        `ifdef DEBUGTB
            $display("f- A: %0f, B: %0f", fA, fB);
            $display("bits- A: %h, B: %h", iA, iB);
            $display("bus- A: %h, B: %h", bus.A, bus.B);
            $display("f- X: %0f", unionX.f);
        `endif

        if (bus.normalizedExponent !== iEx[30:23])
        begin
            error++;
            $display("Expected Normalized Exponent: %h, but Received: %h",
            iEx[30:23], bus.normalizedExponent);
        end
        if(bus.normalizedMantissa !== iEx[22:0])
        begin
            error++;
            $display("Expected Normalized Mantissa: %h, but Received: %h",
            iEx[22:0], bus.normalizedMantissa);
        end
        if(bus.normalizedSign !== iEx[31])
        begin
            error++;
            $display("Expected Normalized Sign: %h, but Received: %h",
            iEx[31], bus.normalizedSign);
        end

        if (error == 0) $display("FP Adder passed static case. Test Passed");
        else            $display("FP Adder failed static case. Test Failed. Total Errors: %0d", error);

        $finish;
    end
endmodule
