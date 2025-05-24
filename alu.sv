//Module to Add Aligned Values Together

module ALU(fpbus.alu bus);

    logic [26:0] extendedResult;

    always_comb 
    begin

        bus.carryOut = 0;

        if (bus.signA == bus.signB)
        begin
            if      (bus.exponentA > bus.exponentB) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
            else if (bus.exponentB > bus.exponentA) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} + {bus.alignedMantissaB, 3'b0};
            else                                    {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, 3'b0};
            
            bus.alignedResult = extendedResult [26:3];
            bus.alignedSign = bus.signA;
        end

        else 
        begin
            if (bus.alignedMantissaA > bus.alignedMantissaB)
            begin
                if      (bus.exponentA > bus.exponentB) {extendedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
                else if (bus.exponentB > bus.exponentA) {extendedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaB, 3'b0};
                else                                    {extendedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, 3'b0};
                
                bus.alignedResult = extendedResult [26:3];
                bus.alignedSign = bus.signA;
            end

            else
            begin
                if      (bus.exponentA > bus.exponentB) {extendedResult} = {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaA, 3'b0};
                else if (bus.exponentB > bus.exponentA) {extendedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit};
                else                                    {extendedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, 3'b0};
                
                bus.alignedResult = extendedResult [26:3];
                bus.alignedSign = bus.signB;
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
