//Module to Compare Exponents for Aligning Mantissa Bits for Addition
module Alignment (fpbus.align bus);

    //Local Variables
    logic [7:0] exponentDifferential;                                                       
    logic [25:0] extendedMantissaA, extendedMantissaB;                                      
    int i;                                                                                  

    // internal control signals
    logic Aex, Bex;

    always_comb
    begin
        Aex = bus.exponentA > bus.exponentB;
        Bex = bus.exponentA < bus.exponentB;
    end


    always_comb
    begin
        bus.BypassALU = 1'b0;
        //Initialize Tracked Rounding Bits
        {bus.guardBit, bus.roundBit, bus.stickyBit} = '0;   

        if (bus.ANaN || bus.BNaN || bus.Ainf || bus.Binf || bus.Azero || bus.Bzero) 
            bus.BypassALU = 1'b1;


        //  Subnormal
        else if (bus.Asub || bus.Bsub)
        begin
            //A and B are both Subnormal
            if (bus.Asub && bus.Bsub )                                       
            begin
                {bus.exponentOut, exponentDifferential} = '0;                                                                                                                
                bus.alignedMantissaA = {1'b0, bus.mantissaA};
                bus.alignedMantissaB = {1'b0, bus.mantissaB};
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), "Subnormal"));
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), "Subnormal"));                                                                                                    
            end
            //Only A is  Subnormal
            else if (bus.Asub)                                                       
            begin
                bus.exponentOut = bus.exponentB;
                exponentDifferential = bus.exponentB - 1;
                bus.alignedMantissaB = {1'b1, bus.mantissaB};                                                                                
                {bus.alignedMantissaA, bus.guardBit, bus.roundBit} = {1'b0, bus.mantissaA, 2'b0} >> exponentDifferential;                                             
                if (exponentDifferential > 26)         
                    bus.stickyBit = |{1'b0, bus.mantissaA, 2'b0};
                else
                    bus.stickyBit = |({1'b0, bus.mantissaA, 2'b0} & ((1 << exponentDifferential) - 1));  
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), "Subnormal"));
            end
            //Only B is Subnormal
            else                                                      
            begin
                bus.exponentOut = bus.exponentA;
                exponentDifferential = bus.exponentA - 1;                                                                                      
                bus.alignedMantissaA = {1'b1, bus.mantissaA};                          
                {bus.alignedMantissaB, bus.guardBit, bus.roundBit} = {1'b0, bus.mantissaB, 2'b0} >> exponentDifferential;
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |{1'b0, bus.mantissaB, 2'b0};                                      
                else                                                                  
                    bus.stickyBit = |({1'b0, bus.mantissaB, 2'b0} & ((1 << exponentDifferential) - 1));       
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), "Subnormal"));                                                                                                    $display("Addend B is %s%s", (bus.signB ? "-" : "+"), "Subnormal"));                                                                                                    $display("Addend B is %s%s", (bus.signB ? "-" : "+"), "Subnormal"));
            end
        end
        // Valid Floating Point Numbers                                
        else
        begin
            //Add Implicit One and Space for Guard and Round Bits
            extendedMantissaA = {1'b1, bus.mantissaA, 2'b0};
            extendedMantissaB = {1'b1, bus.mantissaB, 2'b0};

            //Case Exponent "A" > "B"
            if (Aex)                                              
            begin
                //Choose A Exponent, Set Differential for Normalization to (A - B), Set Aligned "A" to Extended "A"
                exponentDifferential = bus.exponentA - bus.exponentB;
                bus.alignedMantissaA = extendedMantissaA[25:2];            
                bus.exponentOut = bus.exponentA;

                //Shift Aligned "B" to the Right by the Exponent Differential, Set Guard and Round Bits
                {bus.alignedMantissaB, bus.guardBit, bus.roundBit} = extendedMantissaB >> exponentDifferential;
                //Set Sticky Bit to the Reduction OR of the Shifted Out "B" Bits with Implicit One       
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |extendedMantissaB;                                     
                else                                                                  
                    bus.stickyBit = |(extendedMantissaB & ((1 << exponentDifferential) - 1));
            end
            //Case Exponent "B" > "A"
            else if (Bex)                                         
            begin
                //Choose B Exponent, Set Differential for Normalization to (B - A), Set Aligned "B" to Extended "B"
                exponentDifferential = bus.exponentB - bus.exponentA;                       
                bus.alignedMantissaB = extendedMantissaB[25:2];                            
                bus.exponentOut = bus.exponentB;                                            

                //Shift Aligned "A" to the Right by the Exponent Differential, Set Guard and Round Bits
                {bus.alignedMantissaA, bus.guardBit, bus.roundBit} = extendedMantissaA >> exponentDifferential; 
                //Set Sticky Bit to the Reduction OR of the Shifted Out "A" Bits with Implicit One
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |extendedMantissaA;                                      
                else                                                                  
                    bus.stickyBit = |(extendedMantissaA & ((1 << exponentDifferential) - 1));    
            end
            //Case Exponent "A" = "B"
            else                                                                            
            begin
                exponentDifferential = 0;                                                   
                bus.alignedMantissaA = extendedMantissaA[25:2];                             
                bus.alignedMantissaB = extendedMantissaB[25:2];                             
                bus.exponentOut = bus.exponentA;                                            
            end
        end

        `ifdef FULLDEBUG
            `define DEBUGALIGN
        `endif

        `ifdef DEBUGALIGN
        $display("\nMODULE ALIGNMENT---------------------------");
        $display("exponentDifferential: %0d, exponentOut: %h (%0d)", exponentDifferential, bus.exponentOut, bus.exponentOut);
        $display("alignedMantissaA: %h (%b), alignedMantissaB: %h (%b)", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Guard Bit: %0b, Round Bit: %0b, Sticky Bit: %0b\n", bus.guardBit, bus.roundBit, bus.stickyBit);
        $display("Bypass ALU: %b", bus.BypassALU);
        `endif
    end

endmodule
