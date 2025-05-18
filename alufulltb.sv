//Module to Test FPAdder ALU Function
module top;

    //Module Instantiations
    fpbus bus(.*);
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);

    int i, Error;
    logic expectedSign;
    logic [26:0] expectedResult;
    logic [7:0] expectedExponent;

    initial begin
        Error = 0;
        for (i = 0; i < 1000000; i++) 
        begin
            //Generate Random 32-bit Inputs
            bus.A = $urandom_range(0, 32'hFFFFFFFF);
            bus.B = $urandom_range(0, 32'hFFFFFFFF);
            #10;

            if (bus.exponentA == 8'hFF || bus.exponentB == 8'hFF || bus.exponentA == 0 || bus.exponentB == 0) begin
                continue; // Skip NaN, Inf, Zero, Subnormal
            end

            //Determine Expected Exponent
            if (bus.exponentA > bus.exponentB)
                expectedExponent = bus.exponentA;
            else if (bus.exponentB > bus.exponentA)
                expectedExponent = bus.exponentB;
            else
                expectedExponent = bus.exponentA;

            //Check Exponent Output
            if (bus.exponentOut !== expectedExponent) 
            begin
                $display("Case A = %h, B = %h | Incorrect Exponent: Expected %h, Got %h", 
                         bus.A, bus.B, expectedExponent, bus.exponentOut);
                Error++;
            end

            //Determine Expected Result and Sign
            if (bus.signA == bus.signB)
            begin
                //Addition
                if (bus.exponentA > bus.exponentB)
                    {expectedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
                else if (bus.exponentB > bus.exponentA)
                    {expectedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} + {bus.alignedMantissaB, 3'b0};
                else
                    {expectedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, 3'b0};
                expectedSign = bus.signA;
            end
            else
            begin
                //Subtraction
                if (bus.alignedMantissaA > bus.alignedMantissaB)
                begin
                    if (bus.exponentA > bus.exponentB)
                        {expectedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
                    else if (bus.exponentB > bus.exponentA)
                        {expectedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaB, 3'b0};
                    else
                        {expectedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, 3'b0};
                    expectedSign = bus.signA;
                end
                else
                begin
                    if (bus.exponentA > bus.exponentB)
                        {expectedResult} = {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaA, 3'b0};
                    else if (bus.exponentB > bus.exponentA)
                        {expectedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit};
                    else
                        {expectedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, 3'b0};
                    expectedSign = bus.signB;
                end
            end

            //Check Result
            if ({bus.carryOut, bus.alignedResult} !== expectedResult[26:3]) 
            begin
                $display("Case A = %h, B = %h | Incorrect Result: Expected %h, Got %h", 
                         bus.A, bus.B, expectedResult[26:3], {bus.carryOut, bus.alignedResult});
                Error++;
            end

            //Check Sign
            if (bus.alignedSign !== expectedSign) 
            begin
                $display("Case A = %h, B = %h | Incorrect Sign: Expected %b, Got %b", 
                         bus.A, bus.B, expectedSign, bus.alignedSign);
                Error++;
            end
        end

        $display("Simulation Completed With %0d %s.", Error, (Error == 1) ? "Error" : "Errors");
        $finish;
    end
endmodule