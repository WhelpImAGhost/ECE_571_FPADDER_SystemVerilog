package roundingUtil;

    // Rounding function for IEEE 754 Round to Nearest, tie to Even rounding standard
    // Inputs ALU CarryOut, Guard, Round, and Sticky bits from Normalize, and the 32-bit mantissa that needs rounding
    function automatic [32:0] rounding(input logic carryOut ,guardBit, roundBit, stickyBit, [32:0] mantissa);
        if (guardBit && (roundBit || stickyBit || (carryOut ? mantissa[9] : mantissa[8]))) return mantissa + (1 << 8);
        return mantissa;
    endfunction

endpackage
