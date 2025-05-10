//Module to Renormalize the Result

module Normalize(fpbus.normal bus);
    logic [23:0] shiftedMantissa;
    logic [4:0] shiftAmount;

    // Count Leading Zeros in a 24-bit Number (23-bit Mantissa + Implicit 1)
    function automatic [4:0] countZeros(input logic [23:0] mantissa);
        int i;                                          
        shiftAmount = 0;                                      

        for (i = 23; i >= 0; i--)
            if (mantissa[i])
                return 23 - i;                  

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
            bus.normalizedExponent = bus.exponentOut - shiftAmount;
            bus.normalizedSign = bus.alignedSign;
        end
    end

endmodule