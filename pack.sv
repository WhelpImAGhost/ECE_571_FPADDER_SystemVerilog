//Module to Repack Result into IEEE-754 Standardized Format
module Pack(fpbus.pack bus);
    assign bus.Result = {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa};
endmodule