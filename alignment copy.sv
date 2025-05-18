//Module to Compare Exponents for Aligning Mantissa Bits for Addition
module Alignment (fpbus.align bus);

    //Local Variables
    logic [7:0] exponentDifferential;                                                       
    logic [25:0] extendedMantissaA, extendedMantissaB;                                      
    int i;                                                                                  

    always_comb
    begin

        //Initialize Tracked Rounding Bits
        bus.guardBit, bus.roundBit, bus.stickyBit = 0;   

        if (bus.exponentA == 0 && bus.exponentB == 0)                                       //Case Both Exponents are Zero
        begin
            exponentDifferential = 0;                                                       //Set Exponent Differential to Zero
            bus.exponentOut = 0;                                                            //Set Exponent Out to Zero
            bus.alignedMantissaA = {1'b0, bus.mantissaA, 2'b0};                                                       
            bus.alignedMantissaB = {1'b0, bus.mantissaB, 2'b0};                                                                                                        
        end
        else if (bus.exponentA == 0)                                                        //Case "A" Exponent is Zero
        begin
        exponentDifferential = bus.exponentB;                                               //Set Exponent Differential to Zero
            bus.exponentOut = bus.exponentB;                                                //Set Exponent Out to "B"
            bus.alignedMantissaA = {1'b0, bus.mantissaA, 2'b0};                                                           
            bus.alignedMantissaB = {1'b1, bus.mantissaB, 2'b0};                             //Set Aligned "B" to Extended "B"                                                 
        end
        else if (bus.exponentB == 0)                                                        //Case "B" Exponent is Zero
        begin
            exponentDifferential = bus.exponentA;                                           //Set Exponent Differential to Zero
            bus.exponentOut = bus.exponentA;                                                //Set Exponent Out to "A"
            bus.alignedMantissaA = {1'b1, bus.mantissaA, 2'b0};                             //Set Aligned "A" to Extended "A"
            bus.alignedMantissaB = {1'b0, bus.mantissaB, 2'b0};                                                                                            
        end
        else
        begin
            extendedMantissaA = {1'b1, bus.mantissaA, 2'b0};                                //Add Implicit One to "A" Before Shift
            extendedMantissaB = {1'b1, bus.mantissaB, 2'b0};                                //Add Implicit One to "B" Before Shift

            if (bus.exponentA > bus.exponentB)                                              //Case "A" > "B"
            begin
                exponentDifferential = bus.exponentA - bus.exponentB;                       //Subtract Smaller Exponent From Larger
                bus.alignedMantissaA = extendedMantissaA[25:2];                             //Set Aligned "A" = Extended "A"
                bus.exponentOut = bus.exponentA;                                            //Pass Out Exponent A

                //Shift Aligned "B" to the Right by the Exponent Differential, Set Guard and Round Bits
                {bus.alignedMantissaB, bus.guardBit, bus.roundBit} = extendedMantissaB >> exponentDifferential;       
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |extendedMantissaB;                                     //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
                else     
                    //Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One                                                               
                    bus.stickyBit = |(extendedMantissaB & ((1 << exponentDifferential) - 1));
            end

            else if (bus.exponentB > bus.exponentA)                                         //Case "B" > "A"
            begin
                exponentDifferential = bus.exponentB - bus.exponentA;                       //Subtract Smaller Exponent From Larger
                bus.alignedMantissaB = extendedMantissaB[25:2];                             //Set Aligned "B" = Extended "B"
                bus.exponentOut = bus.exponentB;                                            //Pass Out Exponent B

                //Shift Aligned "A" to the Right by the Exponent Differential, Set Guard and Round Bits
                {bus.alignedMantissaA, bus.guardBit, bus.roundBit} = extendedMantissaA >> exponentDifferential; 
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = extendedMantissaA;                                      //Set Sticky Bit to the Reduction OR of the Mantissa with Implicit One
                else                    
                    //Set Sticky Bit to the Reduction OR of the Shifted Out Bits with Implicit One                                                
                    bus.stickyBit = |(extendedMantissaA & ((1 << exponentDifferential) - 1));    
            end

            else                                                                            //Case "A" = "B"
            begin
                exponentDifferential = 0;                                                   //Set Exponent Differential to Zero
                bus.alignedMantissaA = extendedMantissaA[25:2];                             //Aligned "A" = Extended "A"
                bus.alignedMantissaB = extendedMantissaB[25:2];                             //Set Aligned "B" = Extended "B"
                bus.exponentOut = bus.exponentA;                                            //Pass Out Exponent A
            end
        end

        `ifdef FULLDEBUG
            `define DEBUGALIGN
        `endif

        `ifdef DEBUGALIGN
        $display("\nMODULE ALIGNMENT---------------------------");
        $display("exponentDifferential: %0d, exponentOut: %h (%0d)", exponentDifferential, bus.exponentOut, bus.exponentOut);
        $display("extendedMantissaA: %h (%b), extendedMantissaB: %h (%b)", extendedMantissaA, extendedMantissaA, extendedMantissaB, extendedMantissaB);
        $display("alignedMantissaA: %h (%b), alignedMantissaB: %h (%b)", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Guard Bit: %0b, Round Bit: %0b, Sticky Bit: %0b\n", bus.guardBit, bus.roundBit, bus.stickyBit);
        `endif
    end

endmodule
