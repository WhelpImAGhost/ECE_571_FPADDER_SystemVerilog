module top;

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

    // Case 2: A is neg B is pos
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    // Case 3: A is pos B is neg
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 1;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h240000;
    #10;


    // Case 4: A is pos B is neg
    // B has larger mantissa
    bus.signA = 1;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h040000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    // Case 5: both are pos
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    // Case 6: both are pos
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

    // Case 7: both are neg
    // A has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h440000;
    bus.alignedMantissaB = 23'h002000;
    #10;

    // Case 8: both are neg
    // B has larger mantissa
    bus.signA = 0;
    bus.signB = 0;
    bus.alignedMantissaA = 23'h002000;
    bus.alignedMantissaB = 23'h440000;
    #10;

end
endmodule