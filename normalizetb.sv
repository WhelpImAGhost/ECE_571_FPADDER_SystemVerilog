module top;

    int error, tests;

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

    always_comb 
    begin
        bus.A = unionA.bits;
        bus.B = unionB.bits;
        unionX.f = unionA.f + unionB.f;
    end

    initial
    begin 

        // Assign inputs and outputs to bitwise unions
        unionA.f = -1.245;
        unionB.f = 2.753;

        `ifdef DEBUGTB
            $display("f- A: %0f, B: %0f", unionA.f, unionB.f);
            $display("bits- A: %h, B: %h", unionA.bits, unionB.bits);
            $display("bus- A: %h, B: %h", bus.A, bus.B);
            $display("f- X: %f", unionX.f);
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
        else            $display("FP Adder failed static case. Test Failed. Total Errors: %0d", error);

        $finish;
    end
endmodule
