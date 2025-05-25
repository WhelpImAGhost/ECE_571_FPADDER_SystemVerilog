//Module to Add Aligned Values Together

module ALU(fpbus.alu bus);

    logic [31:0] extendedResult;

    always_comb 
    begin
        //Defaults
        bus.carryOut        = 0;
        bus.alignedResult   = 'z;
        bus.alignedSign     = 'z;

        if (!bus.BypassALU)
        begin
            if (bus.signA == bus.signB)
            begin
                {bus.carryOut, extendedResult} = bus.alignedMantissaA + alignedMantissaB;
                
                bus.alignedResult = extendedResult [31:];
                bus.alignedSign = bus.signA;
            end

            else 
            begin
                if (bus.alignedMantissaA > bus.alignedMantissaB)
                begin
                    extendedResult = bus.alignedMantissaA - alignedMantissaB;
                    
                    bus.alignedResult = extendedResult [31:];
                    bus.alignedSign = bus.signA;
                end

                else
                begin
                    extendedResult = bus.alignedMantissaA - alignedMantissaB;
                    
                    bus.alignedResult = extendedResult [31:];
                    bus.alignedSign = bus.signB;
                end
            end
        end


    `ifdef FULLDEBUG 
        `define DEBUGALU
    `endif

    `ifdef DEBUGALU
        $display("\nMODULE ALU---------------------------");
        $display("Input Mantissas- A: %h (%b) B: %h (%b) ", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
        $display("Input Exponents- A: %b (%0d) B: %b (%0d) ", bus.exponentA, bus.exponentA, bus.exponentB, bus.exponentB);
        $display("Intermediate Result: %h (%b) ", extendedResult, extendedResult);
        $display("Aligned Result: %h (%b) ", bus.alignedResult, bus.alignedResult);
        $display("Carry Out: %0b", bus.carryOut);
        $display("Aligned Sign: %0b\n", bus.alignedSign);
    `endif

    end
endmodule
