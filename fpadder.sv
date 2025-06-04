module fpadder(input logic [31:0] A, B, output logic [31:0] Result);

    // Initialize adder interface
    fpbus bus();

    // Initialize submodules
    Mask mask(bus.mask);
    Alignment align(bus.align);
    ALU alu(bus.alu);
    Normalize norm(bus.normal);
    Pack pack(bus.pack);

    assign bus.A = A;
    assign bus.B = B;
    assign Result = bus.Result;
endmodule
