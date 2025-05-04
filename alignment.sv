//Module to Compare Exponents for Aligning Mantissa Bits for Addition

module Alignment(
    input logic [7:0] exponentA, exponentB,
    input logic [22:0] mantissaA, mantissaB,
    output logic [23:0] alignedMantissaA, alignedMantissaB,
    output logic [7:0] exponentOut
);

logic [7:0] exponentDifferential;                                       //Variable to Hold Computed Exponent Different for Shifting
logic [23:0] extendedMantissaA, extendedMantissaB;                      //Extended Mantissa with Added Implicit Ones

always_comb
begin
    extendedMantissaA = {1'b1, mantissaA};                              //Add Implicit One to "A" Before Shift
    extendedMantissaB = {1'b1, mantissaB};                              //Add Implicit One to "B" Before Shift

    if (exponentA > exponentB)                                          //Case "A" > "B"
    begin
        exponentDifferential = exponentA - exponentB;                   //Subtract Smaller Exponent From Larger
        alignedMantissaA = extendedMantissaA;                           //Set Aligned "A" = Extended "A"
        alignedMantissaB = extendedMantissaB >> exponentDifferential;   //Set Aligned "B" = (Extended "B" >> Difference in Exponents)
        exponentOut = exponentA;                                        //Pass Out Exponent A
    end
    else if (exponentB > exponentA)                                     //Case "B" > "A"
    begin
        exponentDifferential = exponentB - exponentA;                   //Subtract Smaller Exponent From Larger
        alignedMantissaB = extendedMantissaB;                           //Set Aligned "B" = Extended "B"
        alignedMantissaA = extendedMantissaA >> exponentDifferential;   //Set Aligned "A" = (Extended "A" >> Difference in Exponents)
        exponentOut = exponentB;                                        //Pass Out Exponent B
    end
    else                                                                //Case "A" = "B"
    begin
        alignedMantissaA = extendedMantissaA;                           //Aligned "A" = Extended "A"
        alignedMantissaB = extendedMantissaB;                           //Set Aligned "B" = Extended "B"
        exponentOut = exponentA;                                        //Pass Out Exponent A
    end
end

endmodule