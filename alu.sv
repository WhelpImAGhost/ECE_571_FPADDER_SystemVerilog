//Module to Add Aligned Values Together
module ALU(fpbus.alu bus);
    always_comb 
    begin
        //Defaults
        bus.carryOut        = 0;
        bus.alignedResult   = 0;
        bus.alignedSign     = 0;

        if (!bus.BypassALU)
        begin
            if (bus.signA == bus.signB)
            begin
                {bus.carryOut, bus.alignedResult} = bus.alignedMantissaA + bus.alignedMantissaB;
                bus.alignedSign = bus.signA;
            end
            else 
            begin
                if (bus.alignedMantissaB > bus.alignedMantissaA)
                begin
                    bus.alignedResult = bus.alignedMantissaA - bus.alignedMantissaB;
                    bus.alignedSign = bus.signB;
                end
                else
                begin
                    bus.alignedResult = bus.alignedMantissaA - bus.alignedMantissaB;
                    bus.alignedSign = bus.signA;
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
            $display("Aligned Result: %h (%b) ", bus.alignedResult, bus.alignedResult);
            $display("Carry Out: %0b", bus.carryOut);
            $display("Aligned Sign: %0b\n", bus.alignedSign);
        `endif

    end
endmodule