//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa;
    logic [4:0] shiftAmount;                                           

    //Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
    function automatic [4:0] countZeros(input logic [23:0] mantissa);
        int i;                                          
        for (i = 23; i >= 0; i--)
            if (mantissa[i])    return 23 - i;    
        return 24;              
    endfunction

    always_comb
    begin 
        //Zero or Denormalized Cases
        if (bus.exponentOut == 0 )             
        begin
            bus.normalizedMantissa = bus.alignedResult;                                 
            bus.normalizedExponent = 0;
            bus.normalizedSign = bus.alignedSign;
        end
        // NaN and Inf cases
        else if (bus.exponentOut == 8'hff) 
        begin
            // A NaN B anything
            if (bus.exponentA == 8'hFF && bus.mantissaA != 23'b0)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
            // A anything B NaN
            else if (bus.exponentB == 8'hFF && bus.mantissaB != 23'b0)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
            // A inf B anything
            else if ((bus.exponentA == 8'hFF && bus.mantissaA == 23'b0) && (bus.exponentB == 8'hFF && bus.mantissaB == 23'b0) )
            begin
                if (bus.signA == bus.signB)
                    {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
                else
                    {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = {1'b0, 8'hFF, 23'h7FFFFF};
            end
            else if ((bus.exponentA == 8'hFF && bus.mantissaA == 23'b0))
                 {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
            else 
                 {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
        end
        //Non-Zero Case
        else
        begin      
            //Normalization
            shiftAmount = countZeros(bus.alignedResult);                //Count Leading Zeros
            shiftedMantissa = bus.alignedResult << shiftAmount; 
            bus.normalizedSign = bus.alignedSign;
            //Check for Overflow
            if ((bus.exponentOut + bus.carryOut) >= 255)
            begin
                bus.normalizedExponent = 255;
            bus.normalizedMantissa = shiftedMantissa[22:0];             //If 0 Infinity, if Non-Zero NaN
            end
            //Handle Carry-Out
            else if (bus.carryOut == 1)
            begin
                shiftAmount = 0;
                shiftedMantissa = {1'b0, bus.alignedResult[23:1]};
                bus.normalizedExponent = bus.exponentOut + 1;
            end 
            //Underflow or Valid Case
            else
            begin                   
                //Check for Underflow
                if ((bus.exponentOut - shiftAmount) > bus.exponentOut)
                begin
                    bus.normalizedExponent = 255;
                    bus.normalizedMantissa = shiftedMantissa [22:0];    //If 0 Infinity, if Non-Zero NaN
                end
                //Valid Case
                else
                begin
                    bus.normalizedExponent = bus.exponentOut - shiftAmount;  
                    //Round-to-Nearest (Even)
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
                            $display("Round Down (No Change)");
                        `endif
                    end
                end
            end
        end

        `ifdef FULLDEBUG 
            `define DEBUGNORM
        `endif
        
        `ifdef DEBUGNORM
        $display("\nMODULE NORMALIZE---------------------------");
	    $display("shiftedMantissa: %h (%b), shiftAmount: %h", shiftedMantissa,shiftedMantissa, shiftAmount);
        $display("normalizedExponent: %h (d:%0d),   normalizedSign: %b", bus.normalizedExponent, bus.normalizedExponent, bus.normalizedSign);
        $display("normalizedMantissa %h (%b)\n", bus.normalizedMantissa,bus.normalizedMantissa);
        `endif

    end
endmodule
