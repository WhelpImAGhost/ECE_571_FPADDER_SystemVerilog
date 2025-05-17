//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa, mask;
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

            //Guard Bit Calculation
            if ((shiftAmount > 0) && (23 - shiftAmount - 1 >= 0))
                guardBit = bus.alignedResult[23 - shiftAmount - 1];                                         
            else
                guardBit = 0;

            //Round Bit Calculation
            if ((shiftAmount > 1) && (23 - shiftAmount - 2 >= 0))
                roundBit = bus.alignedResult[23 - shiftAmount - 2];                     
            else
                roundBit = 0;

            //Sticky Bit Calculation
            if (shiftAmount > 2)
            begin
                mask = (1 << (shiftAmount - 2)) - 1;
                sticky = bus.stickyBit | (| (bus.alignedResult & mask));
            end
            else
                sticky = bus.stickyBit;

            bus.normalizedMantissa = shiftedMantissa [22:0];

            //Round-to-Nearest-Even
            if (guardBit && (roundBit || sticky || bus.normalizedMantissa[0]))        
                bus.normalizedMantissa += 1;

                //Check for Overflow
            if (bus.normalizedMantissa == 0)
                bus.normalizedExponent = bus.exponentOut - shiftAmount + 1;
            else
                bus.normalizedExponent = bus.exponentOut - shiftAmount;

            bus.normalizedSign = bus.alignedSign;
        end

        `ifdef DEBUGNORM
            $display("ShMta: %h     Mask: %h",shiftedMantissa, mask);
            $display("ShAmt: %d", shiftAmount);
            $display("Guard %b      Sticky %b       Round %b", guardBit, sticky, roundBit);
        `endif
    end

endmodule
