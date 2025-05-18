//Module to Unpack Inputs Into Correct Field

module Mask(fpbus.mask bus);

    always_comb
    begin

        bus.signA = bus.A [31];         //Sign Bit for Addend "A"
        bus.signB = bus.B [31];         //Sign Bit for Addend "B"
        bus.exponentA = bus.A [30:23];  //8-Bit Exponent Field for Addend "A"
        bus.exponentB = bus.B [30:23];  //8-Bit Exponent Field for Addend "B"
        bus.mantissaA = bus.A [22:0];   //23-Bit Exponent Field for Addend "A"
        bus.mantissaB = bus.B [22:0];   //23-Bit Exponent Field for Addend "B"

        `ifdef DEBUGMASK
            $display("Sign A: %0b Sign B: %0b\nEx A: %0b Ex B: %0b\nMan A: %0b Man B: %0b\n", bus.signA, bus.signB, bus.exponentA,
                    bus.exponentB, bus.mantissaA, bus.mantissaB);
        `endif

        `ifdef FULLDEBUG
            $display("\nMODULE MASK---------------------------");
            $display("Inputs- A: %h (%b) B: %h (%b) ", bus.A, bus.A, bus.B, bus.B);
            $display("Sign A: %0b Sign B: %0b\nEx A: %0b Ex B: %0b\n Mantissa A: %0b Mantissa B: %0b\n", bus.signA, bus.signB, bus.exponentA,
                    bus.exponentB, bus.mantissaA, bus.mantissaB);
        `endif
    end

endmodule
