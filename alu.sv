//Module to Add Aligned Values Together
module ALU(fpbus.alu bus);
    always_comb 
    begin
        //Defaults
        bus.carryOut        = 0;
        bus.alignedResult   = 0;
        bus.alignedSign     = 0;

        if (!bus.bypassALU)
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
                    if (bus.shiftOverflow)   bus.alignedResult = (bus.alignedMantissaB - bus.alignedMantissaA) - 1;
                    else                     bus.alignedResult = bus.alignedMantissaB - bus.alignedMantissaA;
                    bus.alignedSign = bus.signB;
                end
                else
                begin
                    if (bus.shiftOverflow)   bus.alignedResult = (bus.alignedMantissaA - bus.alignedMantissaB) - 1;
                    else                     bus.alignedResult = bus.alignedMantissaA - bus.alignedMantissaB;
                    bus.alignedSign = bus.signA;
                end
            end
        end

        `ifdef FULLDEBUG 
            `define DEBUGALU
        `endif

        //`ifdef DEBUGALU
        if ((bus.A == 32'hf6fa6276) && (bus.B == 32'h108c442b))
        begin
            $display("\nMODULE ALU---------------------------");
            $display("Input Mantissas- A: %h (%b) B: %h (%b) ", bus.alignedMantissaA, bus.alignedMantissaA, bus.alignedMantissaB, bus.alignedMantissaB);
            $display("Aligned Result: %h (%b) ", bus.alignedResult, bus.alignedResult);
            $display("Carry Out: %0b", bus.carryOut);
            $display("Aligned Sign: %0b\n", bus.alignedSign);
        end
        //`endif

    end
endmodule
