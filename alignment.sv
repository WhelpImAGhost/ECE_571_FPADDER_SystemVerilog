//Module to Compare Exponents for Aligning Mantissa Bits for Addition

// module Alignment(
//     input logic [7:0] bus.exponentA, bus.exponentB,
//     input logic [22:0] bus.mantissaA, bus.mantissaB,
//     output logic [23:0] bus.alignedMantissaA, bus.alignedMantissaB,
//     output logic [7:0] bus.exponentOut
// );

module Alignment (fpbus.align bus);

logic [7:0] exponentDifferential;                                               //Variable to Hold Computed Exponent Different for Shifting
logic [23:0] extendedMantissaA, extendedMantissaB;                              //Extended Mantissa with Added Implicit Ones

int i;                                                                          //Loop Variable

always_comb
begin
    extendedMantissaA = {1'b1, bus.mantissaA};                                  //Add Implicit One to "A" Before Shift
    extendedMantissaB = {1'b1, bus.mantissaB};                                  //Add Implicit One to "B" Before Shift
    bus.stickyBit = 0;                                                          //Initialize Sticky Bit to Zero
	
    if (bus.exponentA > bus.exponentB)                                          //Case "A" > "B"
    begin
        exponentDifferential = bus.exponentA - bus.exponentB;                   //Subtract Smaller Exponent From Larger
        bus.alignedMantissaA = extendedMantissaA;                               //Set Aligned "A" = Extended "A"
        bus.alignedMantissaB = extendedMantissaB >> exponentDifferential;       //Set Aligned "B" = (Extended "B" >> Difference in Exponents)
        if (exponentDifferential > 24)                                          
            bus.stickyBit = |extendedMantissaB;                                 //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
        else                                                                    
            bus.stickyBit = |(extendedMantissaB << (24 - exponentDifferential));//Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One
        bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A
    end
    else if (bus.exponentB > bus.exponentA)                                     //Case "B" > "A"
    begin
        exponentDifferential = bus.exponentB - bus.exponentA;                   //Subtract Smaller Exponent From Larger
        bus.alignedMantissaB = extendedMantissaB;                               //Set Aligned "B" = Extended "B"
        bus.alignedMantissaA = extendedMantissaA >> exponentDifferential;       //Set Aligned "A" = (Extended "A" >> Difference in Exponents)
        if (exponentDifferential > 24)                                          
            bus.stickyBit = |extendedMantissaA;                                 //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
        else                                                                    
            bus.stickyBit = |(extendedMantissaA << (24 - exponentDifferential));//Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One
        bus.exponentOut = bus.exponentB;                                        //Pass Out Exponent B
    end
    else                                                                         //Case "A" = "B"
    begin
        bus.alignedMantissaA = extendedMantissaA;                               //Aligned "A" = Extended "A"
        bus.alignedMantissaB = extendedMantissaB;                               //Set Aligned "B" = Extended "B"
        bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A
    end

    `ifdef DEBUGALIGN
	$display("mA: %h mB: %h\neA: %b eB: %b",
	bus.mantissaA, bus.mantissaB,
	bus.exponentA, bus.exponentB);
    $display("aligned mA: %h aligned mB: %h\n", bus.alignedMantissaA, bus.alignedMantissaB);
    `endif
end

endmodule
