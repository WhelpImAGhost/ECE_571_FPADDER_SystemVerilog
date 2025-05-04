//Test Bench to Ensure Proper Partitioning of 32-Bit FP Values

module top();

    bit [31:0] A, B;                        //Inputs A & B
    bit signA, signB;                       //Output Sign Bits
    bit [7:0] exponentA, exponentB;         //Output Exponents
    bit [22:0] mantissaA, mantissaB;        //Output Mantissas

    Mask M(A, B, signA, signB, exponentA, exponentB, mantissaA, mantissaB);

    initial
    begin
        repeat (1024)
        begin
            //Sign Error Check
            if ((signA !== A >> 31) || (signB !== B >> 31))             
                $display("Improper Extraction of Sign Bit for test A = %p B=%p\nExpected Sign A = %p, Calculated Sign A = %p\nExpected Sign B = %p, Calculated Sign B = %p",
                A, B, A >> 31, signA, B >> 31, signB);
            //Exponent Error Check
            if ((exponentA !== ((A >> 24) & 2'hFF)) || (exponentB !== ((B >> 24) & 2'hFF)))
                $display("Improper Extraction of Exponent for test A = %p B=%p\nExpected Exponent A = %p, Calculated Exponent A = %p\nExpected Exponent B = %p, Calculated Exponent B = %p",
                A, B, (A >> 24) & 2'hFF, exponentA, (B >> 24) & 2'hFF, exponentB);
            //Mantissa Error Check
            if ((mantissaA !== (A & 6'h7FFFFF)) || (mantissaB !== (B & 6'h7FFFFF)))
                $display("Improper Extraction of Mantissa for testA = %p B=%p\nExpected Mantissa A = %p, Calculated Mantissa A = %p\nExpected Mantissa B = %p, Calculated Mantissa B = %p",
                A, B, (A & 6'h7FFFFF), mantissaA, (B & 6'h7FFFFF), mantissaB);
        end

        $display("Simulation Finished");
        $finish
    end

endmodule