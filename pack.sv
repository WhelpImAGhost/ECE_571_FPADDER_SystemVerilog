//Module to Repack Result into IEEE-754 Standardized Format

module Pack(fpbus.pack bus);
    bus.result = {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa};
endmodule