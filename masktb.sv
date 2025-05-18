//Test Bench to Ensure Proper Partitioning of 32-Bit FP Values
module top;

    fpbus bus();
    Mask M(.bus(bus.mask));

    initial
    begin
        repeat (1024)
        begin
            bus.A = $random;
            bus.B = $random;
            #10;
            //Sign Error Check
            if ((bus.signA !== bus.A[31]) || (bus.signB !== bus.B[31]))             
                $display("Improper Extraction of Sign Bit for test A = %h B=%h\nExpected Sign A = %h, Calculated Sign A = %h\nExpected Sign B = %h, Calculated Sign B = %h",
                bus.A, bus.B, bus.A[31], bus.signA, bus.B[31], bus.signB);
            //Exponent Error Check
            if ((bus.exponentA !== bus.A [30:23]) || (bus.exponentB !== bus.B [30:23]))
                $display("Improper Extraction of Exponent for test A = %h B=%h\nExpected Exponent A = %h, Calculated Exponent A = %h\nExpected Exponent B = %h, Calculated Exponent B = %h",
                bus.A, bus.B, bus.A[30:23], bus.exponentA, bus.B[30:23], bus.exponentB);
            //Mantissa Error Check
            if ((bus.mantissaA !== bus.A [22:0]) || (bus.mantissaB !== bus.B[22:0]))
                $display("Improper Extraction of Mantissa for test A = %h B=%h\nExpected Mantissa A = %h, Calculated Mantissa A = %h\nExpected Mantissa B = %h, Calculated Mantissa B = %h",
                bus.A, bus.B, bus.A [22:0], bus.mantissaA, bus.B[22:0], bus.mantissaB);
        end

        $display("Simulation Finished");
        $finish;
        
    end

endmodule
