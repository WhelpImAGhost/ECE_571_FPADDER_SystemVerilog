//Module to Test FPAdder Alignment Function

module top;
    // bit [31:0] A, B;                                    //Inputs A & B
    // bit bus.signA, bus.signB;                                   //Output Sign Bits
    // bit [7:0] bus.exponentA, bus.exponentB;                     //Output Exponents
    // bit [22:0] bus.mantissaA, bus.mantissaB;                    //Output Mantissas
    // bit [7:0] bus.exponentOut;                              //Exponent Used for Normalization
    // bit [23:0] bus.alignedMantissaA, bus.alignedMantissaB;      //Output Extended Mantissa

    int Error;                                          //Error Accumulator

    fpbus bus (.*);

    Mask M(.bus(bus.mask));
    Alignment A1(.bus(bus.align));

    initial
    begin
        repeat (2 << 20)
        begin
            bus.A = $random;
            bus.B = $random;
            #10;
            `ifdef DEBUGTB
	            $display("\n\nA: %h	B: %h", bus.A, bus.B);
		    $display("Af: %e	Bf: %e", $bitstoshortreal(bus.A), $bitstoshortreal(bus.B));
	            $display("Aex: %h (%d)\nBex: %h (%d)", bus.exponentA, bus.exponentA, bus.exponentB, bus.exponentB);
	            $display("AM: %h\nBM: %h", bus.mantissaA, bus.mantissaB);
            `endif
            if (bus.exponentA > bus.exponentB)
            begin
                if(bus.exponentOut !== bus.A[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %h, but Received: %h",
                    bus.A[30:23], bus.exponentOut);
`ifdef DEBUGTB
$stop;
`endif
                end
                if(bus.alignedMantissaB !== ({1'b1,bus.mantissaB} >> (bus.exponentA - bus.exponentB)))
                begin
                    Error++;
                    $display("Expected Aligned B Mantissa: %h, but Received: %h",
                    ({1'b1,bus.mantissaB} >> (bus.exponentA - bus.exponentB)), bus.alignedMantissaB);
`ifdef DEBUGTB
$stop;
`endif
                end

                if(bus.alignedMantissaA !== {1'b1,bus.mantissaA})
                begin
                    Error++;
                    $display("Expected A Mantissa: %h, but Received: %h",
                    {1'b1,bus.mantissaA}, bus.alignedMantissaA);
`ifdef DEBUGTB
$stop;
`endif
                end
            end
            else if (bus.exponentB > bus.exponentA)
            begin
                if(bus.exponentOut !== bus.B[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %h, but Received: %h",
                    bus.B[30:23], bus.exponentOut);
                end
                if(bus.alignedMantissaA !== ({1'b1,bus.mantissaA} >> (bus.exponentB - bus.exponentA)))
                begin
                    Error++;
                    $display("Expected Aligned A Mantissa: %h, but Received: %h",
                    ({1'b1,bus.mantissaA} >> (bus.exponentB - bus.exponentA)), bus.alignedMantissaA);
`ifdef DEBUGTB
$stop;
`endif
                end
                if(bus.alignedMantissaB !== {1'b1,bus.mantissaB})
                begin
                    Error++;
                    $display("Expected B Mantissa: %h, but Received: %h",
                    {1'b1,bus.mantissaB}, bus.alignedMantissaB);
                end
            end
            else
            begin
                if(bus.exponentOut !== bus.A[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %h, but Received: %h",
                    bus.A[30:23], bus.exponentOut);
`ifdef DEBUGTB
$stop;
`endif
                end
                if(bus.alignedMantissaA !== {1'b1,bus.mantissaA})
                begin
                    Error++;
                    $display("Expected A Mantissa : %h, but Received: %h",
                    {1'b1,bus.mantissaA}, bus.alignedMantissaA);
`ifdef DEBUGTB
$stop;
`endif
                end
                if(bus.alignedMantissaB !== {1'b1,bus.mantissaB})
                begin
                    Error++;
                    $display("Expected B Mantissa: %h, but Received: %h",
                    {1'b1,bus.mantissaB}, bus.alignedMantissaB);
`ifdef DEBUGTB
$stop;
`endif
                end
            end
        end
        $display("Simulation finished with %d %s\n", Error, (Error === 1 ? "Error" : "Errors"));
        $finish;
    end

endmodule
