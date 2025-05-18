//Module to Compare Exponents for Aligning Mantissa Bits for Addition
module Alignment (fpbus.align bus);

    //Local Variables
    logic [7:0] exponentDifferential;                                                       
    logic [25:0] extendedMantissaA, extendedMantissaB;                                      
    int i;                                                                                  

    always_comb
    begin

        //Initialize Tracked Rounding Bits
        {bus.guardBit, bus.roundBit, bus.stickyBit} = '0;   

        // +/- Infinity or NaN 
        if (bus.exponentA == 8'hFF || bus.exponentB == 8'hFF)
        begin
            //A and B are both +/- Infinity or NaN
            if (bus.exponentA == 8'hFF && bus.exponentB == 8'hFF)                                       
            begin
                bus.exponentOut = 8'hFF;
                exponentDifferential = 0;                                                                                                                
                bus.alignedMantissaA = {1'b0, bus.mantissaA, 2'b0};
                bus.alignedMantissaB = {1'b0, bus.mantissaB, 2'b0};
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), (bus.mantissaA ? "NaN" : "Infinity"));
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), (bus.mantissaB ? "NaN" : "Infinity"));                                                                                  
            end
            //A is +/- Infinity or NaN
            else if (bus.exponentA == 8'hFF)                                                       
            begin
                bus.exponentOut = 8'hFF;
                exponentDifferential = 0;                                                                                          
                bus.alignedMantissaA = {1'b0, bus.mantissaA, 2'b0};                                                           
                bus.alignedMantissaB = {1'b1, bus.mantissaB, 2'b0};
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), (bus.mantissaA ? "NaN" : "Infinity"));                                                                     
            end
            //B is +/- Infinity or NaN
            else if (bus.exponentB == 8'hFF)                                                      
            begin
                bus.exponentOut = 8'hFF;
                exponentDifferential = 0;                                                                                      
                bus.alignedMantissaA = {1'b1, bus.mantissaA, 2'b0};                          
                bus.alignedMantissaB = {1'b0, bus.mantissaB, 2'b0};                                                                                            
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), (bus.mantissaB ? "NaN" : "Infinity"));                                                                                        
            end
        end
        // +/- Zero or Subnormal
        else if (bus.exponentA == 0 || bus.exponentB == 0)
        begin
            //A and B are both +/- Zero or Subnormal
            if (bus.exponentA == 0 && bus.exponentB == 0)                                       
            begin
                {bus.exponentOut, exponentDifferential} = '0;                                                                                                                
                bus.alignedMantissaA = {1'b0, bus.mantissaA, 2'b0};                                                       
                bus.alignedMantissaB = {1'b0, bus.mantissaB, 2'b0};  
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), (bus.mantissaA ? "Subnormal" : "Zero"));
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), (bus.mantissaB ? "Subnormal" : "Zero"));                                                                                                           
            end
            //A is +/- Zero or Subnormal
            else if (bus.exponentA == 0)                                                       
            begin
                bus.exponentOut = bus.exponentB;
                exponentDifferential = bus.exponentB;
                bus.alignedMantissaB = {1'b1, bus.mantissaB, 2'b0};                                                                                          
                {bus.alignedMantissaA, bus.guardBit, bus.roundBit} = {1'b0, bus.mantissaA, 2'b0} >> exponentDifferential;                                                         
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |{1'b0, bus.mantissaA, 2'b0};                                      
                else                                                                  
                    bus.stickyBit = |({1'b0, bus.mantissaA, 2'b0} & ((1 << exponentDifferential) - 1));  
                $display("Addend A is %s%s", (bus.signA ? "-" : "+"), (bus.mantissaA ? "Subnormal" : "Zero"));
            end
            //B is +/- Zero or Subnormal
            else if (bus.exponentB == 0)                                                      
            begin
                bus.exponentOut = bus.exponentA;
                exponentDifferential = bus.exponentA;                                                                                      
                bus.alignedMantissaA = {1'b1, bus.mantissaA, 2'b0};                          
                {bus.alignedMantissaB, bus.guardBit, bus.roundBit} = {1'b0, bus.mantissaB, 2'b0} >> exponentDifferential;
                if (exponentDifferential > 26)                                          
                    bus.stickyBit = |{1'b0, bus.mantissaB, 2'b0};                                      
                else                                                                  
                    bus.stickyBit = |({1'b0, bus.mantissaB, 2'b0} & ((1 << exponentDifferential) - 1));       
                $display("Addend B is %s%s", (bus.signB ? "-" : "+"), (bus.mantissaB ? "Subnormal" : "Zero"));                                                                                        
            end
        end
        //Valid Floating Point Numbers                                
        else
        begin
            //Add Implicit One and Space for Guard and Round Bits
            extendedMantissaA = {1'b1, bus.mantissaA, 2'b0};
            extendedMantissaB = {1'b1, bus.mantissaB, 2'b0};

            //Case Exponent "A" > "B"
            if (bus.exponentA > bus.exponentB)                                              
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
            else if (bus.exponentB > bus.exponentA)                                         
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
        $display("extendedMantissaA: %h (%b), extendedMantissaB: %h (%b)", extendedMantissaA, extendedMantissaA, extendedMantissaB, extendedMantissaB);
        $display("alignedMantissaA: %h (%b), alignedMantissaB: %h (%b)", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Guard Bit: %0b, Round Bit: %0b, Sticky Bit: %0b\n", bus.guardBit, bus.roundBit, bus.stickyBit);
        `endif
    end

endmodule
