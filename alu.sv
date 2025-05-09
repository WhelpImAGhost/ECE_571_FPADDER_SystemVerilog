//Module to Add Aligned Values Together

module ALU(fpbus.alu bus);

    always_comb 
    begin
        if (bus.signA == bus.signB)
            {bus.carryOut,bus.alignedResult} = bus.alignedMantissaA + bus.alignedMantissaB;
        else 
        begin
            bus.carryOut = 0;
            if (bus.signA < bus.signB)
                bus.alignedResult = bus.alignedMantissaA - bus.alignedMantissaB;
            else
                bus.alignedResult = bus.alignedMantissaB - bus.alignedMantissaA;
        end
    end

endmodule