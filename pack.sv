//Module to Repack Result into IEEE-754 Standardized Format
module Pack(fpbus.pack bus);
    assign bus.Result = {bus.normalizedSign, bus.normalizedExponent, bus.normalizedMantissa};

    `ifdef FULLDEBUG
        `define DEBUGPACK
    `endif

    `ifdef DEBUGPACK
        //enter display here
    `endif
endmodule