module top;

int error;
fpbus bus();
ALU alu1 (.bus(bus.alu));

initial
begin
    error = 0;

    // Case 1: A neg, B pos, A larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h440000;
    bus.alignedMantissaB = 24'h240000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.alignedSign, bus.alignedResult} !== {1'b1, (24'h440000 - 24'h240000)}) begin
        error++;
        $display("Failed case 1: got %b %h, expected %b %h", bus.alignedSign, 
                 bus.alignedResult, 1'b1, 24'h440000 - 24'h240000);
    end

    // Case 2: A neg, B pos, B larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h040000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.alignedSign, bus.alignedResult} !== {1'b0, (24'h440000 - 24'h040000)}) begin
        error++;
        $display("Failed case 2: got %b %h, expected %b %h", bus.alignedSign, 
                 bus.alignedResult, 1'b0, 24'h440000 - 24'h040000);
    end

    // Case 3: A pos, B neg, A larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h440000;
    bus.alignedMantissaB = 24'h240000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.alignedSign, bus.alignedResult} !== {1'b0, (24'h440000 - 24'h240000)}) begin
        error++;
        $display("Failed case 3: got %b %h, expected %b %h", bus.alignedSign, 
                 bus.alignedResult, 1'b0, 24'h440000 - 24'h240000);
    end

    // Case 4: A pos, B neg, B larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h040000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.alignedSign, bus.alignedResult} !== {1'b1, (24'h440000 - 24'h040000)}) begin
        error++;
        $display("Failed case 4: got %b %h, expected %b %h", bus.alignedSign, 
                 bus.alignedResult, 1'b1, 24'h440000 - 24'h040000);
    end

    // Case 5: Both pos, A larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h440000;
    bus.alignedMantissaB = 24'h002000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b0, 1'b0, (24'h440000 + 24'h002000)}) begin
        error++;
        $display("Failed case 5: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b0, 1'b0, 24'h440000 + 24'h002000);
    end

    // Case 6: Both pos, B larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h002000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b0, 1'b0, (24'h440000 + 24'h002000)}) begin
        error++;
        $display("Failed case 6: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b0, 1'b0, 24'h440000 + 24'h002000);
    end

    // Case 7: Both neg, A larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h440000;
    bus.alignedMantissaB = 24'h002000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b0, 1'b1, (24'h440000 + 24'h002000)}) begin
        error++;
        $display("Failed case 7: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b0, 1'b1, 24'h440000 + 24'h002000);
    end

    // Case 8: Both neg, B larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'h002000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b0, 1'b1, (24'h440000 + 24'h002000)}) begin
        error++;
        $display("Failed case 8: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b0, 1'b1, 24'h440000 + 24'h002000);
    end

    // Case 9: Both neg, intend for carryout
    bus.signA = 1;
    bus.signB = 1;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'hF02000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b1, 1'b1, (24'hF02000 + 24'h440000)}) begin
        error++;
        $display("Failed case 9: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b1, 1'b1, (24'hF02000 + 24'h440000));
    end

    // Case 10: Both pos, intend for carryout
    bus.signA = 0;
    bus.signB = 0;
    bus.exponentA = 8'h7F;
    bus.exponentB = 8'h7F;
    bus.alignedMantissaA = 24'hF02000;
    bus.alignedMantissaB = 24'h440000;
    bus.guardBit = 0;
    bus.roundBit = 0;
    bus.stickyBit = 0;
    #10;
    if ({bus.carryOut, bus.alignedSign, bus.alignedResult} !== {1'b1, 1'b0, (24'hF02000 + 24'h440000)}) begin
        error++;
        $display("Failed case 10: got %b %b %h, expected %b %b %h", bus.carryOut, bus.alignedSign, 
                 bus.alignedResult, 1'b1, 1'b0, (24'hF02000 + 24'h440000));
    end


    $display("Simulation finished with %d %s\n", error, (error == 1 ? "Error" : "Errors"));
    $finish;
end
endmodule
