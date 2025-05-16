module top;
parameter Tests = 4096;

// logic [31:0] A, B, X;
shortreal floatA, floatB, floatX;
int error, tests;
bit [31:0] rawA, rawB;

// Initialize bus
fpbus bus();

// Initialize adder with bus
Mask M(.bus(bus.mask));
Alignment A1(.bus(bus.align));
ALU alu1 (.bus(bus.alu));
Normalize N1(.bus(bus.normal));
Pack P1(.bus(bus.pack));

// Create a union to easily switch between 
// bit representation and shortreal representation

    shortreal A, B, X;
    logic [31:0] bitsA, bitsB, bitsX;

    always_comb 
    begin
        bitsA = $shortrealtobits(A);
        bitsB = $shortrealtobits(B);
        X     = A + B;
        bitsX = $shortrealtobits(X);

        bus.A = bitsA;
        bus.B = bitsB;
    end


initial
begin

    // Start with a static test
	A = -1.245;
	B = 2.753;
    #10;


    // Check results. If failing, end the simulation
    if ( X !== A + B)
    begin
        error++;
        $display("FP Adder failed static case. Test Failed");
        $finish;
    end

    // do begin
    //     tests++;

    //     // Generate random (non-NAN/INF) values
    //     do  rawA = $urandom;  while (rawA[30:23] == 8'hFF);
    //     do  rawB = $urandom;  while (rawB[30:23] == 8'hFF);
    //     unionA.bits = rawA;
    //     unionB.bits = rawB;
            
    //     #10
    //     `ifdef DEBUGTB
    //         $display("Adding %e and %e resulted in %e, expected is %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
    //         $display("A: %b		B: %b		Act: %b		Ex: %b", unionA.bits, unionB.bits, unionX.bits, unionA.bits + unionB.bits );

    //     `endif
    //     //  Check results and report errors
    //     if ( unionX.f !== unionA.f + unionB.f)
    //     begin
    //         error++;
    //         $display("FP adder failed. Adding %e and %e resulted in %e instead of %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
    //         $display("A: %b		B: %b		Act: %b		Ex: %b", unionA.bits, unionB.bits, unionX.bits, unionA.bits + unionB.bits );
    //     end
    // end
    // while (tests <= Tests);    

    if (error)
	    $display("%d Errors found in FP adder test", error);
    else
	    $display("No errors found in FP adder test");
    $finish;
end
endmodule

