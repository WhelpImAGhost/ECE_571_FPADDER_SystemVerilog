//Module to Compare Exponents for Aligning Mantissa Bits for Addition

// module Alignment(
//     input logic [7:0] bus.exponentA, bus.exponentB,
//     input logic [22:0] bus.mantissaA, bus.mantissaB,
//     output logic [23:0] bus.alignedMantissaA, bus.alignedMantissaB,
//     output logic [7:0] bus.exponentOut
// );

module Alignment (fpbus bus);

logic [7:0] exponentDifferential;                                       //Variable to Hold Computed Exponent Different for Shifting
logic [23:0] extendedMantissaA, extendedMantissaB;                      //Extended Mantissa with Added Implicit Ones

always_comb
begin
    extendedMantissaA = {1'b1, bus.mantissaA};                              //Add Implicit One to "A" Before Shift
    extendedMantissaB = {1'b1, bus.mantissaB};                              //Add Implicit One to "B" Before Shift

    if (bus.exponentA > bus.exponentB)                                          //Case "A" > "B"
    begin
        exponentDifferential = bus.exponentA - bus.exponentB;                   //Subtract Smaller Exponent From Larger
        bus.alignedMantissaA = extendedMantissaA;                           //Set Aligned "A" = Extended "A"
        bus.alignedMantissaB = extendedMantissaB >> exponentDifferential;   //Set Aligned "B" = (Extended "B" >> Difference in Exponents)
        bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A
    end
    else if (bus.exponentB > bus.exponentA)                                     //Case "B" > "A"
    begin
        exponentDifferential = bus.exponentB - bus.exponentA;                   //Subtract Smaller Exponent From Larger
        bus.alignedMantissaB = extendedMantissaB;                           //Set Aligned "B" = Extended "B"
        bus.alignedMantissaA = extendedMantissaA >> exponentDifferential;   //Set Aligned "A" = (Extended "A" >> Difference in Exponents)
        bus.exponentOut = bus.exponentB;                                        //Pass Out Exponent B
    end
    else                                                                //Case "A" = "B"
    begin
        bus.alignedMantissaA = extendedMantissaA;                           //Aligned "A" = Extended "A"
        bus.alignedMantissaB = extendedMantissaB;                           //Set Aligned "B" = Extended "B"
        bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A
    end
end

endmodule