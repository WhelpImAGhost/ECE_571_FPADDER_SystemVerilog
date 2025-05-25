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

        //Assign All Control Defaults to 0
        {bus.Ainf, bus.ANaN, bus.Asub, bus.Azero, bus.Anormal} = '0;
        {bus.Binf, bus.BNaN, bus.Bsub, bus.Bzero, bus.Bnormal} = '0;
    
        //Input A Control Signals
        case (bus.exponentA)
            0:
                if (bus.mantissaA == 0) bus.Azero   = 1;
                else                    bus.Asub    = 1;
            255:
                if (bus.mantissaA == 0) bus.Ainf    = 1;
                else                    bus.ANaN    = 1;
            default:                    bus.Anormal = 1;
        endcase

        //Input B Control Signals
        case (bus.exponentB)
            0:
                if (bus.mantissaB == 0) bus.Bzero   = 1;
                else                    bus.Bsub    = 1;
            255:
                if (bus.mantissaB == 0) bus.Binf    = 1;
                else                    bus.BNaN    = 1;
            default:                    bus.Bnormal = 1;
        endcase

        `ifdef FULLDEBUG
            `define DEBUGMASK
        `endif

        `ifdef DEBUGMASK
            $display("\nMODULE MASK---------------------------");
            $display("Inputs- A: %h (%32b) B: %h (%32b) ", 
                    bus.A, bus.A, bus.B, bus.B);
            $display("Sign A: %b Exponent A: %h (%8b) Mantissa A: %h (%23b)\nSign B: %b Exponent B: %h (%8b) Mantissa B: %h (%23b)\n",
                    bus.signA, bus.exponentA, bus.exponentA, bus.mantissaA, bus.mantissaA, bus.signB, bus.exponentB, bus.exponentB, bus.mantissaB, bus.mantissaB);
            $display("Input A Control Signals- Ainf %b, ANaN %b, Asub %b, Azero %b, Anormal %b\nInput B Control Signals- Binf %b, BNaN %b, Bsub %b, Bzero %b, Bnormal %b\n",
                    bus.Ainf, bus.ANaN, bus.Asub, bus.Azero, bus.Anormal, bus.Binf, bus.BNaN, bus.Bsub, bus.Bzero, bus.Bnormal);
        `endif
    end

endmodule