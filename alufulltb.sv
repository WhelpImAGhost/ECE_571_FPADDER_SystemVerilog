module top;

    //Module Instantiations
    fpbus bus(.*);
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);

    int i, Error;
    logic expectedSign;
    logic [24:0] expectedSum;
    logic [7:0] expectedExponent;

    initial begin
        for (i = 0; i < 1000000; i++) 
        begin
            //Generate Random 32-bit Inputs
            bus.A = $urandom_range(0, 32'hFFFFFFFF);
            bus.B = $urandom_range(0, 32'hFFFFFFFF);
            #1; //Allow Propagation

            //Determine Expected exponent
            if (bus.exponentA > bus.exponentB)
                expectedExponent = bus.exponentA;
            else if (bus.exponentB > bus.exponentA)
                expectedExponent = bus.exponentB;
            else
                expectedExponent = bus.exponentA;

            //Check Exponent Output
            if (bus.exponentOut !== expectedExponent) 
            begin
                $display("Case A = %h, B = %h | Incorrect Exponent: Expected %h, Got %h", bus.A, bus.B, expectedExponent, bus.exponentOut);
                Error++;
            end

            //Determine Expected Mantissa Addition Based on Exponent Alignment
            if (bus.signA == bus.signB)
                    expectedSum = bus.alignedMantissaA + bus.alignedMantissaB;
            else
            if (bus.alignedMantissaA > bus.alignedMantissaB)
                expectedSum = bus.alignedMantissaA - bus.alignedMantissaB;
            else if (bus.alignedMantissaB > bus.alignedMantissaA)
                expectedSum = bus.alignedMantissaB - bus.alignedMantissaA;

            //Check Eesult
            if ({bus.carryOut, bus.alignedResult} !== expectedSum) 
            begin
                $display("Case A = %h, B = %h | Incorrect Result: Expected %h, Got %h", bus.A, bus.B, expectedSum, {bus.carryOut, bus.alignedResult});
                Error++;
            end

            //Check Sign
            if (bus.exponentA > bus.exponentB)
                expectedSign = bus.signA;
            else if (bus.exponentB > bus.exponentA)
                expectedSign = bus.signB;
            else
                expectedSign = bus.signA;

            if (bus.alignedSign !== expectedSign) 
            begin
                $display("Case A = %h, B = %h | Incorrect Sign: Expected %b, Got %b", bus.A, bus.B, expectedSign, bus.alignedSign);
                Error++;
            end
        end

        $display("Simulation Completed With %0d %s.", Error, (Error == 1) ? "Error" : "Errors");
    end
endmodule
