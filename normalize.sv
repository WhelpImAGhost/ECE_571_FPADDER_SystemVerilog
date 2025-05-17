//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa;
    logic [4:0] shiftAmount;
    logic guardBit, roundBit, sticky;                                              

    // Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
    function automatic [4:0] countZeros(input logic [23:0] mantissa);
        int i;                                          
        shiftAmount = 0;                                      

        for (i = 23; i >= 0; i--)
            if (mantissa[i])
                return 23 - i;                  
        return 24;                  //If All Bits are Zero, Return 24
    endfunction

    always_comb begin
        if (bus.alignedResult == 0)             
        begin
            bus.normalizedMantissa = 0;                                 
            bus.normalizedExponent = 0;
            bus.normalizedSign = 0;
        end 
        else
        begin
            shiftAmount = countZeros(bus.alignedResult);                    
            shiftedMantissa = bus.alignedResult << shiftAmount;         

            bus.normalizedMantissa = shiftedMantissa [22:0];

            //Round-to-Nearest-Even
            if (bus.guardBit)
                if (bus.roundBit || bus.stickyBit)
                    bus.normalizedMantissa += 1; 
                else if (bus.normalizedMantissa[0])
                    bus.normalizedMantissa += 1;
            

            bus.normalizedExponent = bus.exponentOut - shiftAmount;
            bus.normalizedSign = bus.alignedSign;
        end

        `ifdef DEBUGNORM
            $display("ShMta: %h", shiftedMantissa);
            $display("ShAmt: %d", shiftAmount);
            $display("Guard %b      Sticky %b       Round %b", bus.guardBit, bus.stickyBit, bus.roundBit);
        `endif
    end

endmodule
