//Module to Renormalize the Result
module Normalize(fpbus.normal bus);
    logic [31:0] shiftedMantissa;
    logic [5:0] shiftAmount;   
    logic roundCarry, guard, round, sticky;                                      

    function automatic [5:0] countZeros(input logic [31:0] result);
        int i;                                          
        for (i = 31; i >= 0; i--)
            if (result[i])    return 31 - i;               
    endfunction

    always_comb
    begin 
        //NaN or Infinity Cases
        if (bus.ANaN || bus.BNaN || bus.Ainf || bus.Binf)
        begin
            if (bus.ANaN)       {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
            else if (bus.BNaN)  {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
            else if (bus.Ainf)
            begin
                if (bus.Binf && (bus.signA !== bus.signB))  
                    {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = {1'b0, 8'hFF, 23'h7FFFFF};
                else
                    {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;    
            end
            else if (bus.Binf)  {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
        end

        //Zero Case
        else if (bus.Azero || bus.Bzero)
        begin
            if (bus.Azero && bus.Bzero)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
            else if (bus.Azero)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
            else
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
        end

        //Normal or Subnormal Cases
        else
        begin      
            bus.normalizedSign = bus.alignedSign;
            //Handle Carry-Out
            if (bus.carryOut == 1)
            begin
                shiftAmount = 0;
                shiftedMantissa = {bus.alignedResult, bus.guardBit, bus.roundBit} << shiftAmount;
                {guard, round, sticky} = {bus.guardBit, bus.roundBit, bus.stickyBit} << shiftAmount;
                bus.normalizedMantissa =  shiftedMantissa[25:3];
                //Check for Overflow
                if ((bus.exponentOut + bus.carryOut) >= 255)
                begin
                    bus.normalizedExponent = 255;
                    bus.normalizedMantissa = shiftedMantissa[24:2];        //If 0 Infinity, if Non-Zero NaN 
                end
                else    bus.normalizedExponent = bus.exponentOut + 1;      //Increment Exponent Out
            end 
            //Normal Cases
            else
            begin     
                shiftAmount = countZeros(bus.alignedResult);    //Count Leading Zeros  
                shiftedMantissa = {bus.alignedResult, bus.guardBit, bus.roundBit} << shiftAmount;
                {guard, round, sticky} = {bus.guardBit, bus.roundBit, bus.stickyBit} << shiftAmount;         
                //Check for Underflow
                if ((bus.exponentOut - shiftAmount) > bus.exponentOut)
                begin
                    bus.normalizedExponent = 0;
                    bus.normalizedMantissa = shiftedMantissa [24:2];    //If 0 Zero, if Non-Zero Subnormal
                end
                //Regular Case
                else
                begin
                    bus.normalizedExponent = bus.exponentOut - shiftAmount;  
                    //Round-to-Nearest (Even)
                    if (guard) 
                    begin
                        if (round || sticky || shiftedMantissa[2])
                        begin
                            {roundCarry, bus.normalizedMantissa} = shiftedMantissa [24:2] + 1; 
                            if (roundCarry == 1)
                            begin
                                if ((bus.exponentOut + roundCarry) >= 255)  bus.normalizedExponent = 255;
                                else                                        bus.normalizedExponent = bus.exponentOut + 1;
                            end 

                            `ifdef DEBUGNORM
                            $display("Round Up");
                            `endif
                        end
                        else    bus.normalizedMantissa = shiftedMantissa [24:2];
                    end
                    else
                    begin
                        bus.normalizedMantissa = shiftedMantissa [24:2];

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
        $display("Post Shift- Guard: %b, Round: %b, Sticky: %b", guard, round, sticky);
        $display("normalizedExponent: %h (d:%0d),   normalizedSign: %b", bus.normalizedExponent, bus.normalizedExponent, bus.normalizedSign);
        $display("normalizedMantissa %h (%b)\n", bus.normalizedMantissa,bus.normalizedMantissa);
        `endif
    end
endmodule