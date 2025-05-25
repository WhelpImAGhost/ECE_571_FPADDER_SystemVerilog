//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [] shiftedMantissa;
    logic [4:0] shiftAmount;
    logic roundCarry, guard, round, sticky;

    //Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
    function automatic [4:0] countZeros(input logic [23:0] mantissa);
        int i;                                                         
        for (i = 23; i >= 0; i--)
            if (mantissa[i])
                return 23 - i;    
        return 24;              
    endfunction

    //Combinational Block for Handling Different Cases
    always_comb   
    begin
        case(bus.exponentOut)
            //Both Zero or Denormalized Numbers
            0:                  
            begin
                bus.normalizedSign      = bus.alignedSign;
                bus.normalizedExponent  = 0;             
                bus.normalizedMantissa  = bus.alignedResult;
            end
            //Either is Nan or Infinity
            255:
            begin
                //Nan Cases
                //A NaN, B anything, Result is NaN (A)
                if (bus.exponentA == 8'hFF && bus.mantissaA != 23'b0)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.A;
                //A anything, B NaN, Result is NaN (B)
                else if (bus.exponentB == 8'hFF && bus.mantissaB != 23'b0)
                {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa} = bus.B;
            end
            //Normal Numbers
            default:
            begin

            end
        endcase
    end