//Module to Renormalize the Result
module Normalize(fpbus.normal bus);
    logic [31:0] shiftedMantissa, mantissaOut;
    logic [5:0]  shiftAmount;
    logic roundCarry, guard, round, stickyShift;                                      

    function automatic [5:0] countZeros(input logic [31:0] result);
        int i;                                          
        for (i = 31; i >= 0; i--)
            if (result[i])    return 31 - i;
        return 32;               
    endfunction

    function automatic [32:0] rounding(input logic cO ,gB, rB, sB, [32:0] mantissa);
        if (gB && (rB || sB || (cO ? mantissa[9] : mantissa[8]))) return mantissa + (1 << 8);
        return mantissa;
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

        else
        begin      
            bus.normalizedSign = bus.alignedSign;
            shiftAmount = bus.carryOut ? 0 : countZeros(bus.alignedResult);
            mantissaOut = (shiftAmount > bus.exponentOut) ? (bus.alignedResult << bus.exponentOut) :  (bus.alignedResult << shiftAmount);

            guard  =  bus.carryOut ? mantissaOut[8] : mantissaOut[7];
            round  =  bus.carryOut ? mantissaOut[7] : mantissaOut[6];
            stickyShift =  bus.carryOut ? |mantissaOut[6:0] : |mantissaOut[5:0];

            {roundCarry, shiftedMantissa} = rounding(bus.carryOut, guard, round, (bus.sticky | stickyShift), mantissaOut);

            if (bus.carryOut || roundCarry) 
            begin
                bus.normalizedMantissa = (bus.exponentOut + bus.carryOut + roundCarry >= 255) ? 0 : shiftedMantissa[31:9];
                bus.normalizedExponent = (bus.exponentOut + bus.carryOut + roundCarry >= 255) ? 255 : bus.exponentOut + bus.carryOut + roundCarry;
            end
            else 
            begin
                bus.normalizedMantissa = (shiftAmount > bus.exponentOut) ? shiftedMantissa[31:9] : shiftedMantissa[30:8];
                bus.normalizedExponent = (bus.exponentOut <= shiftAmount) ? 0 : bus.exponentOut - shiftAmount;
            end
        end

        `ifdef FULLDEBUG 
            `define DEBUGNORM
        `endif
        
        `ifdef DEBUGNORM
            $display("\nMODULE NORMALIZE---------------------------");
            $display("mantissaOut: %h (%b), shiftAmount: %h", mantissaOut, mantissaOut, shiftAmount);
	        $display("shiftedMantissa: %h (%b)", shiftedMantissa, shiftedMantissa);
            $display("Post Shift- Guard: %b, Round: %b, Sticky: %b", guard, round, bus.sticky);
            $display("normalizedExponent: %h (d:%0d),   normalizedSign: %b", bus.normalizedExponent, bus.normalizedExponent, bus.normalizedSign);
            $display("normalizedMantissa %h (%b)\n", bus.normalizedMantissa, bus.normalizedMantissa);
        `endif
    end
endmodule
