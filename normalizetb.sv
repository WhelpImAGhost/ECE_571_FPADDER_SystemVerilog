module top;
parameter Tests = 2<<20;
    int error, tests;
    shortreal fA, fB, fX;
    bit [31:0] rawA, rawB, iA, iB, iX, iEx;


    fpbus bus();
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);
    Normalize N1(bus.normal);
Pack P1(bus.pack);
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
        fA = -1.140625;
        fB = 1.14111328125;

        #10

        `ifdef DEBUGTB
            $display("f- A: %0f, B: %0f", fA, fB);
            $display("bits- A: %h, B: %h", iA, iB);
            $display("bus- A: %h, B: %h", bus.A, bus.B);
            $display("f- X: %e", fX);
	    $display("f eX: %e", $bitstoshortreal(iEx));
	    $display("i  X: %b", iX);
	    $display("i eX: %b", iEx);
        `endif

        if (bus.normalizedExponent !== iEx[30:23])
        begin
            error++;
            $display("Expected Normalized Exponent: %h, but Received: %h",
            iEx[30:23], bus.normalizedExponent);
`ifdef DEBUGTB2
	    $stop;
`endif
        end
        if (bus.normalizedMantissa !== iEx[22:0] &&
		bus.normalizedMantissa !== iEx[22:0] + 1 &&
		bus.normalizedMantissa !== iEx[22:0] - 1)
        begin
            error++;
            $display("Expected Normalized Mantissa: %h, but Received: %h",
            iEx[22:0], bus.normalizedMantissa);
`ifdef DEBUGTB2
        //    $stop;
`endif
        end
        if(bus.normalizedSign !== iEx[31])
        begin
            error++;
            $display("Expected Normalized Sign: %h, but Received: %h",
            iEx[31], bus.normalizedSign);
`ifdef DEBUGTB2
            $stop;
`endif
        end
        do begin
		tests++;
		rawA = $urandom;
		rawB = $urandom;
            fA = $bitstoshortreal(rawA);
            fB = $bitstoshortreal(rawB);
            #10;

            if (bus.normalizedExponent !== iEx[30:23])
            begin
                error++;
                $display("Expected Normalized Exponent: %h, but Received: %h",
                iEx[30:23], bus.normalizedExponent);
`ifdef DEBUGTB2
            $stop;
`endif
            end
            if (bus.normalizedMantissa !== iEx[22:0] &&
            bus.normalizedMantissa !== iEx[22:0] + 1 &&
            bus.normalizedMantissa !== iEx[22:0] - 1)
            begin
                error++;
                $display("Expected Normalized Mantissa: %h, but Received: %h",
                iEx[22:0], bus.normalizedMantissa);
`ifdef DEBUGTB2
            // $stop;
`endif
            end
            if(bus.normalizedSign !== iEx[31])
            begin
                error++;
                $display("Expected Normalized Sign: %h, but Received: %h",
                iEx[31], bus.normalizedSign);
`ifdef DEBUGTB2
            $stop;
`endif
            end
            
        end
        while (tests <= Tests ); 
        
        if (error == 0) $display("FP Adder passed static case. Test Passed");
        else            $display("FP Adder failed static case. Test Failed. Total Errors: %0d", error);

        $finish;
    end
endmodule
