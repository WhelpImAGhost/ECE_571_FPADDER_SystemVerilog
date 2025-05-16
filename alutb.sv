module top;

int error;

fpbus bus();

//Alignment align1(.bus(bus.align));
//Mask m1(.bus(bus.mask));
ALU alu1 (.bus(bus.alu));

initial
begin

    // Case 1: A is neg B is pos
    // A has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h240000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b1, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 1: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 1, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 2: A is neg B is pos
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b0, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 2: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 0, bus.alignedMantissaB - bus.alignedMantissaA);
    end

    // Case 3: A is pos B is neg
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h240000;
    #10;


    if({bus.alignedSign, bus.alignedResult} !== {1'b0, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 3: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 0, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 4: A is pos B is neg
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    
    if({bus.alignedSign, bus.alignedResult} !== {1'b1, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 4: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 1, bus.alignedMantissaB - bus.alignedMantissaA);
    end

    // Case 5: both are pos
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b0, bus.alignedMantissaA + bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 5: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 0, bus.alignedMantissaA + bus.alignedMantissaB);
    end

    // Case 6: both are pos
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b0, bus.alignedMantissaB + bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 6: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 0, bus.alignedMantissaB + bus.alignedMantissaA);
    end

    // Case 7: both are neg
    // A has larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b1, bus.alignedMantissaA + bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 7: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 1, bus.alignedMantissaA + bus.alignedMantissaB);
    end

    // Case 8: both are neg
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b1, bus.alignedMantissaB + bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 8: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 1, bus.alignedMantissaB + bus.alignedMantissaA);
    end


    // Case 9: Both are neg, intend for carryout
    bus.signA = 1;
    bus.signB = 1;
    bus.alignedMantissaA = 23'hF02000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b1, bus.alignedMantissaB + bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 8: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 1, bus.alignedMantissaB + bus.alignedMantissaA);
    end
    else if (bus.carryOut !== 1'b1) begin
        error++;
        $display("Failed case 9: got %b, expected %0b", bus.carryOut, 1);
    end

    // Case 10: Both are pos, intend for carryout
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'hF02000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.alignedSign, bus.alignedResult} !== {1'b0, bus.alignedMantissaB + bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 10: got %b %h, expected %b %h", bus.alignedSign, 
        bus.alignedResult, 0, bus.alignedMantissaB + bus.alignedMantissaA);
    end
    else if (bus.carryOut !== 1'b1) begin
        error++;
        $display("Failed case 10: got %b, expected %0b", bus.carryOut, 1);
    end


    $display("Simulation finished with %d %s\n", error, (error === 1 ? "Error" : "Errors"));
    $finish;
end
endmodule
