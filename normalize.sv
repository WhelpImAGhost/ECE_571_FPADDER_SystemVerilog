//Module to Renormalize the Result

module Normalize();
    logic [23:0] normInput;
    logic [4:0] shiftAmt;

    always_comb begin
        if (carryOut) begin
            // Overflow occurred — shift right and bump exponent
            normInput = alignedResult >> 1;
            normalizedExponent = exponentIn + 1;
            normalizedMantissa = normInput[22:0];
        end else if (alignedResult == 0) begin
            normalizedMantissa = 0;
            normalizedExponent = 0;
        end else begin
            shiftAmt = 0;
            for (int i = 23; i >= 0; i--) begin
                if (alignedResult[i] == 1) begin
                    shiftAmt = 23 - i;
                    break;
                end
            end
            normInput = alignedResult << shiftAmt;
            normalizedExponent = exponentIn - shiftAmt;
            normalizedMantissa = normInput[22:0];
        end
    end

endmodule