//Module to Add Aligned Values Together

module ALU(fpbus.alu bus);

    always_comb 
    begin
        if (bus.signA == bus.signB)
        begin
            {bus.carryOut, bus.alignedResult} = bus.alignedMantissaA + bus.alignedMantissaB;
            bus.alignedSign = bus.signA;
        end
        else 
        begin
            bus.carryOut = 0;
            if (bus.alignedMantissaA > bus.alignedMantissaB)
            begin
                {bus.carryOut, bus.alignedResult} = bus.alignedMantissaA - bus.alignedMantissaB;
                bus.alignedSign = bus.signA;
            end
            else
            begin
                {bus.carryOut, bus.alignedResult} = bus.alignedMantissaB - bus.alignedMantissaA;
                bus.alignedSign = bus.signB;
            end
        end
    end

endmodule
