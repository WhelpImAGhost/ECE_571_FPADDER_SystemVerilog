//Module to Compare Exponents for Aligning Mantissa Bits for Addition
module Alignment (fpbus.align bus);

    logic [7:0] exponentDifferential;                                                                                                                                                                  
    logic [31:0] extendedMantissa;

    //Control Signals
    assign bus.Aex = (bus.exponentA > bus.exponentB);
    assign bus.Bex = (bus.exponentA < bus.exponentB);
    assign bus.bypassALU = (bus.ANaN | bus.BNaN | bus.Ainf | bus.Binf | bus.Azero | bus.Bzero);  


    //Exponent Calculations
    always_comb
    begin
        if (bus.Aex) 
        begin
            bus.exponentOut = bus.exponentA;
            if (bus.Bsub)   exponentDifferential = bus.exponentA - 1;
            else            exponentDifferential = bus.exponentA - bus.exponentB;
        end
        else if (bus.Bex) 
        begin
            bus.exponentOut = bus.exponentB;
            if (bus.Asub)   exponentDifferential = bus.exponentB - 1;
            else            exponentDifferential = bus.exponentB - bus.exponentA;
        end
        else 
        begin
            bus.exponentOut = bus.exponentA;
            exponentDifferential = 0;
        end
    end


    //Mantissa Calculations
    always_comb
    begin
        if (bus.Aex)                                              
        begin
            bus.alignedMantissaA = {1'b1, bus.mantissaA, 8'b0};
            if (bus.Bsub)   bus.alignedMantissaB = {1'b0, bus.mantissaB, 8'b0} >> exponentDifferential;            
            else            bus.alignedMantissaB = {1'b1, bus.mantissaB, 8'b0} >> exponentDifferential;
        end
        else if (bus.Bex)                                         
        begin                
            bus.alignedMantissaB = {1'b1, bus.mantissaB, 8'b0};            
            if (bus.Asub)   bus.alignedMantissaA = {1'b0, bus.mantissaA, 8'b0} >> exponentDifferential;            
            else            bus.alignedMantissaA = {1'b1, bus.mantissaA, 8'b0} >> exponentDifferential;
        end
        else                                                                            
        begin         
            if (bus.Asub)   bus.alignedMantissaA = {1'b0, bus.mantissaA, 8'b0} >> exponentDifferential;            
            else            bus.alignedMantissaA = {1'b1, bus.mantissaA, 8'b0} >> exponentDifferential;    

            if (bus.Bsub)   bus.alignedMantissaB = {1'b0, bus.mantissaB, 8'b0} >> exponentDifferential;            
            else            bus.alignedMantissaB = {1'b1, bus.mantissaB, 8'b0} >> exponentDifferential;                                                                                       
        end
    end

    //shiftOverflow Bit for Long Subtractions
    always_comb 
    begin
        begin: shiftOverflowCheck
            bus.shiftOverflow = 0;
            if (bus.Aex)
            begin
                extendedMantissa = bus.Bsub ? {1'b0, bus.mantissaB, 8'b0} : bus.alignedMantissaB = {1'b1, bus.mantissaB, 8'b0};
                for(int i = 0; i < exponentDifferential; i++)                                    
                    if (extendedMantissa[i])
                    begin
                    bus.shiftOverflow = 1;
                    disable shiftOverflowCheck;
                    end
            end
            else if (bus.Bex)
            begin
                extendedMantissa = bus.Asub ? {1'b0, bus.mantissaA, 8'b0} : bus.alignedMantissaA = {1'b1, bus.mantissaA, 8'b0};
                for(int i = 0; i < exponentDifferential; i++)                                    
                    if (extendedMantissa[i])
                    begin
                    bus.shiftOverflow = 1;
                    disable shiftOverflowCheck;
                    end
            end
        end
    end    

    //Sticky Bit Calculation
    always_comb
    begin
        if (bus.Aex)
        begin
            if (exponentDifferential > 32)      bus.sticky = |bus.mantissaB;
            else if (exponentDifferential > 2)  bus.sticky = |(bus.mantissaB & ((1 << (exponentDifferential - 2)) - 1));
            else                                bus.sticky = 0;
        end
        else if (bus.Bex)  
        begin
            if (exponentDifferential > 32)      bus.sticky = |bus.mantissaA;
            else if (exponentDifferential > 2)  bus.sticky = |(bus.mantissaA & ((1 << (exponentDifferential - 2)) - 1));
            else                                bus.sticky = 0;
        end
        else                                    bus.sticky = 0;
    end

    //DEBUG Statements
    always_comb
    begin
        `ifdef FULLDEBUG
            `define DEBUGALIGN
        `endif

        `ifdef DEBUGALIGN
        $display("\nMODULE ALIGNMENT---------------------------");
        $display("exponentDifferential: %0d, exponentOut: %h (%0d)", exponentDifferential, bus.exponentOut, bus.exponentOut);
        $display("alignedMantissaA: %h (%b), alignedMantissaB: %h (%b)", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Bypass ALU: %b, shiftOverflow: %b", bus.bypassALU, bus.shiftOverflow);
        `endif
    end
endmodule
