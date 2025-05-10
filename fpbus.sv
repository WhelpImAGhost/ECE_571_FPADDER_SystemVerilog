interface fpbus;
    logic [31:0] A, B, Result;
    logic signA, signB, alignedSign, carryOut, normalizedSign;
    logic [7:0] exponentA, exponentB, exponentOut, normalizedExponent;
    logic [22:0] mantissaA, mantissaB, normalizedMantissa;
    logic [23:0] alignedMantissaA, alignedMantissaB, alignedResult;

    modport mask (input A, B,
                  output signA, signB,
                  output exponentA, exponentB,
                  output mantissaA, mantissaB );

    modport align (input exponentA, exponentB,
                   input mantissaA, mantissaB,
                   output alignedMantissaA, alignedMantissaB,
                   output exponentOut);

    modport alu (input signA, signB,
                 input alignedMantissaA, alignedMantissaB,
                 output alignedResult, alignedSign, carryOut);

    modport normal (input alignedResult, exponentOut, alignedSign,
        output normalizedSign, normalizedExponent, normalizedMantissa);

    modport pack (input normalizedSign, normalizedExponent, normalizedMantissa,
        output result);

endinterface
