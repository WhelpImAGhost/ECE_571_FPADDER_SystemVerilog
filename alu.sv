//Module to Add Aligned Values Together

module ALU(fpbus.alu bus);

    logic [26:0] extendedResult;

    always_comb 
    begin

        if (bus.signA == bus.signB)
        begin
            if      (bus.exponentA > bus.exponentB) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
            else if (bus.exponentB > bus.exponentA) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} + {bus.alignedMantissaA, 3'b0};
            else                                    {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} + {bus.alignedMantissaB, 3'b0};
            
            bus.alignedResult = extendedResult [26:3];
            bus.alignedSign = bus.signA;
        end

        else 
        begin
            bus.carryOut = 0;
            if (bus.alignedMantissaA > bus.alignedMantissaB)
            begin
                if      (bus.exponentA > bus.exponentB) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit};
                else if (bus.exponentB > bus.exponentA) {bus.carryOut, extendedResult} = {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaB, 3'b0};
                else                                    {bus.carryOut, extendedResult} = {bus.alignedMantissaA, 3'b0} - {bus.alignedMantissaB, 3'b0};
                
                bus.alignedResult = extendedResult [26:3];
                bus.alignedSign = bus.signA;
            end
            else
            begin
                if      (bus.exponentA > bus.exponentB) {bus.carryOut, extendedResult} = {bus.alignedMantissaB, bus.guardBit, bus.roundBit, bus.stickyBit} - {bus.alignedMantissaA, 3'b0};
                else if (bus.exponentB > bus.exponentA) {bus.carryOut, extendedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, bus.guardBit, bus.roundBit, bus.stickyBit};
                else                                    {bus.carryOut, extendedResult} = {bus.alignedMantissaB, 3'b0} - {bus.alignedMantissaA, 3'b0};
                
                bus.alignedResult = extendedResult [26:3];
                bus.alignedSign = bus.signB;
            end
        end

        `ifdef DEBUGALU
            $display("Sign: %b, \"Carry Out\": %b, Result: %h", bus.alignedSign, bus.carryOut, bus.alignedResult);
        `endif

    end

endmodule
