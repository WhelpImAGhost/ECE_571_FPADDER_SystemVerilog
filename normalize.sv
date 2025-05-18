//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa;
    logic [4:0] shiftAmount;                                           

    // Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
    function automatic [4:0] countZeros(input logic [23:0] mantissa);
        int i;                                          
        for (i = 23; i >= 0; i--)
            if (mantissa[i])    return 23 - i;                  
    endfunction

    always_comb
    begin

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

            //Round-to-Nearest-Even
            if (bus.guardBit) 
            begin
                if (bus.roundBit || bus.stickyBit || bus.normalizedMantissa[0])
                begin
                    bus.normalizedMantissa = shiftedMantissa [22:0] + 1; 
                    `ifdef DEBUGNORM
                    $display("Round Up");
                    `endif
                end
                else    bus.normalizedMantissa = shiftedMantissa [22:0];
            end

            else
            begin
                bus.normalizedMantissa = shiftedMantissa [22:0];
                `ifdef DEBUGNORM
                    $display("No rounding happened");
                `endif
            end

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
