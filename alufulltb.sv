module top();

    //Module Instantiations
    fpbus bus(.*);
    Mask mask(bus.mask);
    Aligment align(bus.align);
    ALU alu(bus.alu);

    int i; 
    int Error;

    initial begin
        for (i = 0; i < 10000; i++) 
        begin
            //Generate Random 32-bit Inputs
            bus.A = $urandom_range(0, 32'hFFFFFFFF);
            bus.B = $urandom_range(0, 32'hFFFFFFFF);
            #1; //Allow Propagation

            //Determine Expected exponent
            logic [7:0] expectedExponent;
            if (bus.exponentA > bus.exponentB)
                expectedExponent = bus.exponentA;
            else if (bus.exponentB > bus.exponentA)
                expectedExponent = bus.exponentB;
            else
                expectedExponent = bus.exponentA;

            //Check Exponent Output
            if (bus.exponentOut !== expectedExponent) 
            begin
                $display("Incorrect Exponent: Expected %h, Got %h", expectedExponent, bus.exponentOut);
                Error++;
            end

            //Determine Expected Mantissa Addition Based on Exponent Alignment
            logic [24:0] expectedSum;
            if (bus.signA == bus.signB)
                    expectedSum = bus.alignedMantissaA + bus.alignedMantissaA;
            else
            if (bus.alignedMantissaA > bus.alignedMantissaB)
                expectedSum = bus.extendedMantissaA - bus.alignedMantissaB;
            else if (bus.alignedMantissaB > bus.alignedMantissaA)
                expectedSum = bus.extendedMantissaB - bus.alignedMantissaA;

            //Check Eesult
            if ({bus.carryOut, bus.alignedResult} !== expectedSum) 
            begin
                $display("Incorrect Result: Expected %h, Got %h", expectedSum, {bus.carryOut, bus.alignedResult});
                Error++;
            end

            //Check Sign
            logic expectedSign;
            if (bus.exponentA > bus.exponentB)
                expectedSign = bus.signA;
            else if (bus.exponentB > bus.exponentA)
                expectedSign = bus.signB;
            else
                expectedSign = bus.signA;

            if (bus.alignedSign !== expectedSign) 
            begin
                $display("Incorrect Sign: Expected %b, Got %b", expectedSign, bus.alignedSign);
                Error++;
            end
        end

        $display("Simulation Completed With %0d %s.", Error, (Error == 1) ? "Error" : "Errors");
    end
endmodule
