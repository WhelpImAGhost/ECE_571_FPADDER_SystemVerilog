//Test Bench to Ensure Proper Partitioning of 32-Bit FP Values

module top;

    bit [31:0] A, B;                        //Inputs A & B
    bit signA, signB;                       //Output Sign Bits
    bit [7:0] exponentA, exponentB;         //Output Exponents
    bit [22:0] mantissaA, mantissaB;        //Output Mantissas

    Mask M(A, B, signA, signB, exponentA, exponentB, mantissaA, mantissaB);

    initial
    begin
        repeat (1024)
        begin
            #10;
            A = $random;
            B = $random;
            //Sign Error Check
            if ((signA !== A[31]) || (signB !== B[31]))             
                $display("Improper Extraction of Sign Bit for test A = %h B=%h\nExpected Sign A = %h, Calculated Sign A = %h\nExpected Sign B = %h, Calculated Sign B = %h",
                A, B, A[31], signA, B[31], signB);
            //Exponent Error Check
            if ((exponentA !== A [30:23]) || (exponentB !== B [30:23]))
                $display("Improper Extraction of Exponent for test A = %h B=%h\nExpected Exponent A = %h, Calculated Exponent A = %h\nExpected Exponent B = %h, Calculated Exponent B = h",
                A, B, A [30:23], exponentA, B [30:23], exponentB);
            //Mantissa Error Check
            if ((mantissaA !== A [22:0]) || (mantissaB !== B[22:0]))
                $display("Improper Extraction of Mantissa for test A = %h B=%h\nExpected Mantissa A = %h, Calculated Mantissa A = %h\nExpected Mantissa B = %h, Calculated Mantissa B = %h",
                A, B, A [22:0], mantissaA, B[22:0], mantissaB);
        end

        $display("Simulation Finished");
        $finish;
    end

endmodule