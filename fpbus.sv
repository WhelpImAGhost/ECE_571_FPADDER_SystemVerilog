interface fpbus;

    //Initial Inputs & Final Output
    logic [31:0] A, B, Result;
    //Intermediate Sign Calculations
    logic signA, signB, alignedSign, normalizedSign; 
    //Exponents
    logic [7:0] exponentA, exponentB, exponentOut, normalizedExponent;
    //Mantissas
    logic [22:0] mantissaA, mantissaB, normalizedMantissa;
    //Intermediate Results
    logic [31:0] alignedMantissaA, alignedMantissaB, alignedResult;
    logic carryOut;
    //Control Signals
    logic Ainf, Binf, ANaN, BNaN, Asub, Bsub, Azero, Bzero, Anormal, Bnormal;
    logic bypassALU, Aex, Bex;

    modport mask(   input A, B,
                    output signA, signB,
                    output exponentA, exponentB,
                    output mantissaA, mantissaB,
                    output Ainf, ANaN, Asub, Azero, Anormal,
                    output Binf, BNaN, Bsub, Bzero, Bnormal);

    modport align(  input exponentA, exponentB,
                    input mantissaA, mantissaB,
                    input Ainf, ANaN, Asub, Azero, Anormal,
                    input Binf, BNaN, Bsub, Bzero, Bnormal,
                    output alignedMantissaA, alignedMantissaB,
                    output exponentOut,
                    output bypassALU, Aex, Bex);

    modport alu(    input signA, signB,
                    input alignedMantissaA, alignedMantissaB,
                    input bypassALU,
                    output alignedResult, alignedSign, carryOut);

    modport normal( input alignedResult, exponentOut, alignedSign, carryOut,
                    input A, B, exponentA, exponentB, mantissaA, mantissaB, signA, signB,
                    input Ainf, ANaN, Asub, Azero, Anormal,
                    input Binf, BNaN, Bsub, Bzero, Bnormal,
                    output normalizedSign, normalizedExponent, normalizedMantissa);

    modport pack(   input normalizedSign, normalizedExponent, normalizedMantissa,
                    output Result);


endinterface
