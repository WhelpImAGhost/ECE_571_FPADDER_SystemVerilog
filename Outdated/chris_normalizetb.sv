module top;

    int error, tests;

    fpbus bus();
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);
    Normalize N1(bus.normal);

    shortreal A, B, X;
    logic [31:0] bitsA, bitsB, bitsX;

    always_comb 
    begin
        X     = A + B;

        bitsA = $shortrealtobits(A);
        bitsB = $shortrealtobits(B);
        bitsX = $shortrealtobits(X);

        bus.A = bitsA;
        bus.B = bitsB;
    end

    initial
    begin 
        A = -1.245;
        B =  2.753;

        #10

        `ifdef DEBUGTB
            $display("f- A: %0f, B: %0f", A, B);
            $display("bits- A: %h, B: %h", bitsA, bitsB);
            $display("bus- A: %h, B: %h", bus.A, bus.B);
            $display("f- X: %0f", X);
        `endif

        if (bus.normalizedExponent !== bitsX[30:23])
        begin
            error++;
            $display("Expected Normalized Exponent: %h, but Received: %h",
            bitsX[30:23], bus.normalizedExponent);
        end
        if(bus.normalizedMantissa !== bitsX[22:0])
        begin
            error++;
            $display("Expected Normalized Mantissa: %h, but Received: %h",
            bitsX[22:0], bus.normalizedMantissa);
        end
        if(bus.normalizedSign !== bitsX[31])
        begin
            error++;
            $display("Expected Normalized Sign: %h, but Received: %h",
            bitsX[31], bus.normalizedSign);
        end

        if (error == 0) $display("FP Adder passed static case. Test Passed");
        else            $display("FP Adder failed static case. Test Failed. Total Errors: %0d", error);

        $finish;
    end
endmodule
