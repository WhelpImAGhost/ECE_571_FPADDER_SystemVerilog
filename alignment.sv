//Module to Compare Exponents for Aligning Mantissa Bits for Addition

module Alignment (fpbus.align bus);

    logic [7:0] exponentDifferential;                                               //Variable to Hold Computed Exponent Different for Shifting
    logic [25:0] extendedMantissaA, extendedMantissaB;                              //Extended Mantissa with Added Implicit Ones

    int i;                                                                          //Loop Variable

    always_comb
    begin

        extendedMantissaA = {1'b1, bus.mantissaA, 2'b0};                            //Add Implicit One to "A" Before Shift
        extendedMantissaB = {1'b1, bus.mantissaB, 2'b0};                            //Add Implicit One to "B" Before Shift
        bus.stickyBit = 0;                                                          //Initialize Sticky Bit to Zero
        bus.guardBit = 0;                                                           //Initialize Guard Bit to Zero
        bus.roundBit = 0;                                                           //Initialize Round Bit to Zero

        if (bus.exponentA > bus.exponentB)                                          //Case "A" > "B"
        begin
            exponentDifferential = bus.exponentA - bus.exponentB;                   //Subtract Smaller Exponent From Larger
            bus.alignedMantissaA = extendedMantissaA[25:2];                         //Set Aligned "A" = Extended "A"
            bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A

            //Shift Aligned "B" to the Right by the Exponent Differential, Set Guard and Round Bits
            {bus.alignedMantissaB, bus.guardBit, bus.roundBit} = extendedMantissaB >> exponentDifferential;       
            if (exponentDifferential > 26)                                          
                bus.stickyBit = extendedMantissaB;                                  //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
            else                                                                    
                bus.stickyBit = |(extendedMantissaB << (26 - exponentDifferential));//Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One
        end

        else if (bus.exponentB > bus.exponentA)                                     //Case "B" > "A"
        begin
            exponentDifferential = bus.exponentB - bus.exponentA;                   //Subtract Smaller Exponent From Larger
            bus.alignedMantissaB = extendedMantissaB[25:2];                         //Set Aligned "B" = Extended "B"
            bus.exponentOut = bus.exponentB;                                        //Pass Out Exponent B

            //Shift Aligned "A" to the Right by the Exponent Differential, Set Guard and Round Bits
            {bus.alignedMantissaA, bus.guardBit, bus.roundBit} = extendedMantissaA >> exponentDifferential; 
            if (exponentDifferential > 26)                                          
                bus.stickyBit = extendedMantissaA;                                  //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
            else                                                                    
                bus.stickyBit = |(extendedMantissaA << (26 - exponentDifferential));//Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One
        end

        else                                                                        //Case "A" = "B"
        begin
            bus.alignedMantissaA = extendedMantissaA[25:2];                         //Aligned "A" = Extended "A"
            bus.alignedMantissaB = extendedMantissaB[25:2];                         //Set Aligned "B" = Extended "B"
            bus.exponentOut = bus.exponentA;                                        //Pass Out Exponent A
        end

        `ifdef DEBUGALIGN
            $display("mA: %h mB: %h\neA: %b eB: %b",
            bus.mantissaA, bus.mantissaB,
            bus.exponentA, bus.exponentB);
            $display("aligned mA: %h aligned mB: %h\n", bus.alignedMantissaA, bus.alignedMantissaB);
        `endif

        `ifdef FULLDEBUG
        $display("\nMODULE ALIGNMENT---------------------------");
        $display("exponentDifferential: %0d, exponentOut: %h (%0d)", exponentDifferential, bus.exponentOut, bus.exponentOut);
        $display("extendedMantissaA: %h (%b), extendedMantissaB: %h (%b)", extendedMantissaA, extendedMantissaA, extendedMantissaB, extendedMantissaB);
        $display("alignedMantissaA: %h (%b), alignedMantissaB: %h (%b)", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Guard Bit: %0b, Round Bit: %0b, Sticky Bit: %0b\n", bus.guardBit, bus.roundBit, bus.stickyBit);
        `endif
    end

endmodule
