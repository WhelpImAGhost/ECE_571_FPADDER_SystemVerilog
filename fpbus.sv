interface fpbus;
    logic [31:0] A, B, Result;
    logic signA, signB;
    logic [7:0] exponentA, exponentB, exponentOut;
    logic [22:0] mantissaA, mantissaB;
    logic [23:0] alignedMantissaA, alignedMantissaB;
    logic [23:0] alignedResult;
    logic alignedSign;
    logic carryOut;

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

    modport normal (input carryOut, alignedResult
                    

    );

endinterface
