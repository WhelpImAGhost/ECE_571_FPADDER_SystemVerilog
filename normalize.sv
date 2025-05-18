//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa;
    logic [4:0] shiftAmount;                                           

    //Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
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
        end 

        else
        begin      

            //Check for Overflow
            if (bus.carryOut)
            begin
                shiftAmount = 0;
                shiftedMantissa = {1'b0, bus.alignedResult[23:1]};
                bus.normalizedExponent = bus.exponentOut + 1; 
            end
            else
            begin
                shiftAmount = countZeros(bus.alignedResult);                    
                shiftedMantissa = bus.alignedResult << shiftAmount;   
                bus.normalizedExponent = bus.exponentOut - shiftAmount;
            end    

            //Round-to-Nearest-Even
            if (bus.guardBit) 
            begin
                if (bus.roundBit || bus.stickyBit || shiftedMantissa[0])
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

            bus.normalizedSign = bus.alignedSign;
        end

        `ifdef DEBUGNORM
            $display("ShMta: %h", shiftedMantissa);
            $display("ShAmt: %d", shiftAmount);
            $display("Guard %b      Sticky %b       Round %b", bus.guardBit, bus.stickyBit, bus.roundBit);
        `endif
        
        `ifdef FULLDEBUG
        $display("\nMODULE NORMALIZE---------------------------");
	    $display("shiftedMantissa: %h (%b), shiftAmount: %h", shiftedMantissa,shiftedMantissa, shiftAmount);
        $display("normalizedExponent: %h (d:%0d),   normalizedSign: %b", bus.normalizedExponent, bus.normalizedExponent, bus.normalizedSign);
        $display("normalizedMantissa %h (%b)\n", bus.normalizedMantissa,bus.normalizedMantissa);
        `endif

    end
endmodule
