//Module to Renormalize the Result
module Normalize(fpbus.normal bus);
    logic [31:0] shiftedMantissa;
    logic [5:0]  shiftAmount;
    logic roundCarry, guard, round, sticky;                                      

    function automatic [5:0] countZeros(input logic [31:0] result);
        int i;                                          
        for (i = 31; i >= 0; i--)
            if (result[i])    return 31 - i;
        return 32;               
    endfunction

    function automatic [32:0] rounding(input logic gB, input logic rB, input logic sB, input logic [32:0] mantissa);
            if (gB)
            begin
                if (rB || sB || mantissa[8]) return mantissa + (1 << 8);
            end
            return mantissa;
    endfunction    

    //Rounding Bits
    assign guard  =  bus.alignedResult[7];
    assign round  =  bus.alignedResult[6];
    assign sticky = |bus.alignedResult[5:0];

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
            if (carryOut)   shiftAmount = 0;
            else            shiftAmount = countZeros(bus.alignedResult);
            {roundCarry, shiftedMantissa} = rounding(guard, round, sticky, (bus.alignedResult << shiftAmount));
            
            //Handle Carry-Out
            if (bus.carryOut == 1 || roundCarry == 1)
            begin
                bus.normalizedMantissa = shiftedMantissa[31:9];
                //Check for Overflow
                if ((bus.exponentOut + bus.carryOut) >= 255)    bus.normalizedExponent = 255;
                else if ((bus.exponentOut + roundCarry) >= 255) bus.normalizedExponent = 255;
                else                                            bus.normalizedExponent = bus.exponentOut + bus.carryOut + roundCarry;
            end 

            //Normal Cases
            else
            begin    
                bus.normalizedMantissa = shiftedMantissa [30:8];       
                //Check for Underflow
                if ((bus.exponentOut - shiftAmount) > bus.exponentOut)  bus.normalizedExponent = 0;
                //Regular Case
                else    bus.normalizedExponent = bus.exponentOut - shiftAmount;  
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
