//Module to Unpack Inputs Into Correct Field

module Mask(
    input logic [31:0] A, B,
    output logic signA, signB
    output logic [7:0] exponentA, exponentB,
    output logic [22:0] mantissaA, mantissaB
);

    always_comb
    begin
        signA = A [31];         //Sign Bit for Addend "A"
        signB = B [31];         //Sign Bit for Addend "B"
        exponentA = A [30:23];  //8-Bit Exponent Field for Addend "A"
        exponentB = B [30:23];  //8-Bit Exponent Field for Addend "B"
        mantissaA = A [22:0];   //23-Bit Exponent Field for Addend "A"
        mantissaB = B [22:0];   //23-Bit Exponent Field for Addend "B"
    end

endmodule