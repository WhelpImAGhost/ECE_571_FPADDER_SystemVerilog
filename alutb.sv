module top;

int error;

fpbus bus();

Alignment align1(fpbus.align bus);
Mask m1(fpbus.mask bus);
ALU alu1 (fpbus.alu bus);

initial
begin

    // Case 1: A is neg B is pos
    // A has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h240000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {1, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 1: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 1, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 2: A is neg B is pos
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {0, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 2: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 0, bus.alignedMantissaB - bus.alignedMantissaA);
    end

    // Case 3: A is pos B is neg
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h240000;
    #10;


    if({bus.resultSign, bus.alignedResult} !== {0, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 3: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 0, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 4: A is pos B is neg
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    
    if({bus.resultSign, bus.alignedResult} !== {1, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 4: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 1, bus.alignedMantissaB - bus.alignedMantissaA);
    end

    // Case 5: both are pos
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {0, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 5: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 0, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 6: both are pos
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {0, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 6: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 0, bus.alignedMantissaB - bus.alignedMantissaA);
    end

    // Case 7: both are neg
    // A has larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {1, bus.alignedMantissaA - bus.alignedMantissaB}) begin
        error++;
        $display("Failed case 7: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 1, bus.alignedMantissaA - bus.alignedMantissaB);
    end

    // Case 8: both are neg
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    if({bus.resultSign, bus.alignedResult} !== {1, bus.alignedMantissaB - bus.alignedMantissaA}) begin
        error++;
        $display("Failed case 8: got %b %h, expected %b %h", bus.resultSign, 
        alignedResult, 1, bus.alignedMantissaB - bus.alignedMantissaA);
    end


    $display("Simulation finished with %d %s\n", error, (error === 1 ? "Error" : "Errors"));
    $finish;
end
endmodule