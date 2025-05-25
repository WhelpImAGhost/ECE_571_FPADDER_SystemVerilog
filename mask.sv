//Module to Unpack Inputs Into Correct Fields for Addition
module Mask(fpbus.mask bus);

    always_comb
    begin

        //Unpack Addends Signs
        bus.signA = bus.A [31];         
        bus.signB = bus.B [31];         

        //Unpack Addends Exponents
        bus.exponentA = bus.A [30:23];  
        bus.exponentB = bus.B [30:23];  

        //Unpack Addends Mantissas
        bus.mantissaA = bus.A [22:0];   
        bus.mantissaB = bus.B [22:0];   

        `ifdef FULLDEBUG
            `define DEBUGMASK
        `endif

        `ifdef DEBUGMASK
            $display("\nMODULE MASK---------------------------");
            $display("Inputs- A: %h (%32b) B: %h (%32b) ", 
                    bus.A, bus.A, bus.B, bus.B);
            $display("Sign A: %b Sign B: %b\nEx A: %8b Ex B: %8b\nMantissa A: %h (%23b) Mantissa B: %h (%23b)\n",
                    bus.signA, bus.signB, bus.exponentA, bus.exponentB, bus.mantissaA, bus.mantissaA, bus.mantissaB, bus.mantissaB);
        `endif
        
    end

endmodule
