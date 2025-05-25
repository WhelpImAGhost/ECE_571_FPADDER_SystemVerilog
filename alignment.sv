//Module to Compare Exponents for Aligning Mantissa Bits for Addition
module Alignment (fpbus.align bus);

    logic [7:0] exponentDifferential;                                                                                                                                                                  

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
        $display("Bypass ALU: %b", bus.BypassALU);
        `endif
    end
endmodule
