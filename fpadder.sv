module fpadder(fpbus bus);
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);
    Normalize norm(bus.normal);
    Pack pack(bus.pack);
endmodule