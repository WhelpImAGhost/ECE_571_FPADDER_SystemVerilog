interface fpbus;

    //Initial Inputs & Final Output
    logic [31:0] A, B, Result;
    //Intermediate Sign Calculations
    logic signA, signB, alignedSign, normalizedSign; 
    //Rounding Bits
    logic stickyBit, guardBit, roundBit, carryOut;
    //Exponents
    logic [7:0] exponentA, exponentB, exponentOut, normalizedExponent;
    //Mantissas
    logic [22:0] mantissaA, mantissaB, normalizedMantissa;
    //Intermediate Results
    logic [23:0] alignedMantissaA, alignedMantissaB, alignedResult;
    //Control Signals
    logic Ainf, Binf, ANaN, BNaN, Asub, Bsub, Azero, Bzero, Anormal, Bnormal;
    logic BypassALU;

    modport mask (  input A, B,
                    output signA, signB,
                    output exponentA, exponentB,
                    output mantissaA, mantissaB);

    modport align ( input exponentA, exponentB,
                    input mantissaA, mantissaB,
                    input signA, signB,
                    input Ainf, Binf, ANaN, BNaN, Asub, Bsub,
                    input Azero, Bzero, Anormal, Bnormal,
                    output stickyBit, guardBit, roundBit,
                    output alignedMantissaA, alignedMantissaB,
                    output exponentOut,
                    output BypassALU);

    modport alu (   input signA, signB, exponentA, exponentB,
                    input alignedMantissaA, alignedMantissaB,
                    input stickyBit, guardBit, roundBit,
                    output alignedResult, alignedSign, carryOut);

    modport normal (input alignedResult, exponentOut, alignedSign, carryOut,
                    input A, B, exponentA, exponentB, mantissaA, mantissaB, signA, signB,
                    input stickyBit, guardBit, roundBit,
                    output normalizedSign, normalizedExponent, normalizedMantissa);

    modport pack (  input normalizedSign, normalizedExponent, normalizedMantissa,
                    output Result);


endinterface
