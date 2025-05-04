//Module to Test FPAdder Alignment Function

module top;
    bit [31:0] A, B;                                    //Inputs A & B
    bit signA, signB;                                   //Output Sign Bits
    bit [7:0] exponentA, exponentB;                     //Output Exponents
    bit [22:0] mantissaA, mantissaB;                    //Output Mantissas
    bit [7:0] exponentOut;                              //Exponent Used for Normalization
    bit [23:0] alignedMantissaA, alignedMantissaB;      //Output Extended Mantissa

    int Error;                                          //Error Accumulator

    Mask M(A, B, signA, signB, exponentA, exponentB, mantissaA, mantissaB);
    Alignment A1(exponentA, exponentB, mantissaA, mantissaB, alignedMantissaA, alignedMantissaB, exponentOut);

    initial
    begin
        repeat (2048)
        begin
            A = $random;
            B = $random;
            #10;

            if (exponentA > exponentB)
                if(exponentOut !== A[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %d, but Received: %d",
                    A[30:23], exponentOut);
                end
                if(alignedMantissaB !== ({1'b1,mantissaB} >> (exponentA - exponentB)))
                begin
                    Error++;
                    $display("Expected Aligned B Mantissa: %d, but Received: %d",
                    ({1'b1,mantissaB} >> (exponentA - exponentB)), alignedMantissaB);
                end
                if(alignedMantissaA !== {1'b1,mantissaA})
                begin
                    Error++;
                    $display("Expected Mantissa A: %d, but Received: %d",
                    {1'b1,mantissaA}, alignedMantissaA);
                end
            else if (exponentB > exponentA)
                if(exponentOut !== B[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %d, but Received: %d",
                    B[30:23], exponentOut);
                end
                if(alignedMantissaA !== ({1'b1,mantissaA} >> (exponentB - exponentA)))
                begin
                    Error++;
                    $display("Expected Aligned B Mantissa: %d, but Received: %d",
                    ({1'b1,mantissaA} >> (exponentB - exponentA)), alignedMantissaA);
                end
                if(alignedMantissaB !== {1'b1,mantissaB})
                begin
                    Error++;
                    $display("Expected Mantissa A: %d, but Received: %d",
                    {1'b1,mantissaB}, alignedMantissaB);
                end
            else
                if(exponentOut !== A[30:23])
                begin
                    Error++;
                    $display("Expected Normalization Exponent: %d, but Received: %d",
                    A[30:23], exponentOut);
                end
                if(alignedMantissaA !== {1'b1,mantissaA})
                begin
                    Error++;
                    $display("Expected Mantissa A: %d, but Received: %d",
                    {1'b1,mantissaA}, alignedMantissaA);
                end
                if(alignedMantissaB !== {1'b1,mantissaB})
                begin
                    Error++;
                    $display("Expected Aligned B Mantissa: %d, but Received: %d",
                    {1'b1,mantissaB}, alignedMantissaB);
                end
        end
        $display("Simulation finished with %d %s\n", Error, (Error === 1 ? "Error" : "Errors"));
        $finish;
    end

endmodule