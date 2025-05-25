//Module to Unpack Inputs Into Correct Fields for Addition
module Mask(fpbus.mask bus);

    //Unpack Addends Signs
    assign bus.signA = bus.A [31];         
    assign bus.signB = bus.B [31];         

    //Unpack Addends Exponents
    assign bus.exponentA = bus.A [30:23];  
    assign bus.exponentB = bus.B [30:23];  

    //Unpack Addends Mantissas
    assign bus.mantissaA = bus.A [22:0];   
    assign bus.mantissaB = bus.B [22:0];   

    //Combinational Block to Assign Control Signals
    always_comb
    begin
    
        case ({bus.exponentA, bus.mantissaA})
        
        endcase

        case ({bus.exponentB, bus.mantissaB})

        endcase

        `ifdef FULLDEBUG
            `define DEBUGMASK
        `endif

        `ifdef DEBUGMASK
            $display("\nMODULE MASK---------------------------");
            $display("Inputs- A: %h (%32b) B: %h (%32b) ", 
                    bus.A, bus.A, bus.B, bus.B);
            $display("Sign A: %b Sign B: %b\nEx A: %8b Ex B: %8b\nMantissa A: %h (%23b) Mantissa B: %h (%23b)",
                    bus.signA, bus.signB, bus.exponentA, bus.exponentB, bus.mantissaA, bus.mantissaA, bus.mantissaB, bus.mantissaB);
            $display("Input A Control Signals- Ainf %b, ANaN %b, Asub %b, Azero %b, Anormal %b\nInput B Control Signals- Binf %b, BNaN %b, Bsub %b, Bzero %b, Bnormal %b\n",
                    Ainf, ANaN, Asub, Azero, Anormal, Binf, BNaN, Bsub, Bzero, Bnormal);
        `endif
    end

endmodule
