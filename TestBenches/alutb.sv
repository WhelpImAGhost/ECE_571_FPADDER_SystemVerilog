//Module to Test FPAdder ALU Function
module top;

    //Module Instantiations
    fpbus bus(.*);
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);

    int i, Error;
    logic expectedSign;
    logic [32:0] expectedResult;
    logic [7:0] expectedExponent;

    initial begin
        Error = 0;
        for (i = 0; i < 2 << 20; i++) 
        begin
            //Generate Random 32-bit Inputs
            bus.A = $urandom;
            bus.B = $urandom;
            #10;

            if (bus.Azero || bus.Ainf || bus.ANaN || bus.Bzero || bus.Binf || bus.BNaN) begin
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
                expectedResult = bus.alignedMantissaA + bus.alignedMantissaB;
                expectedSign = bus.signA;
            end
            else
            begin
                //Subtraction
                if (bus.alignedMantissaA > bus.alignedMantissaB)
                begin
                    expectedResult = bus.alignedMantissaA - bus.alignedMantissaB;
                    expectedSign = bus.signA;
                end
                else
                begin
                    expectedResult = bus.alignedMantissaB - bus.alignedMantissaA;
                    expectedSign = bus.signB;
                end
            end

            //Check Result
            if ({bus.carryOut, bus.alignedResult} !== expectedResult) 
            begin
                $display("Case A = %h, B = %h | Incorrect Result: Expected %h, Got %h", 
                         bus.A, bus.B, expectedResult, {bus.carryOut, bus.alignedResult});
                Error++;
		$stop;
            end

            //Check Sign
            if (bus.alignedSign !== expectedSign) 
            begin
                $display("Case A = %h, B = %h | Incorrect Sign: Expected %b, Got %b", 
                         bus.A, bus.B, expectedSign, bus.alignedSign);
                Error++;
		$stop;
            end
        end

        $display("Simulation Completed With %0d %s.", Error, (Error == 1) ? "Error" : "Errors");
        $finish;
    end
endmodule
