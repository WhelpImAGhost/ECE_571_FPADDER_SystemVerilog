module top;
parameter Tests = 4096;

// logic [31:0] A, B, X;
shortreal floatA, floatB, floatX;
int error, tests;
bit [31:0] rawA, rawB;

// Initialize bus
fpbus bus();

// Initialize adder with bus
FPAdder f1(.bus(bus));

// Create a union to easily switch between 
// bit representation and shortreal representation
typedef union {
       	shortreal f;
        logic [31:0] bits;
} f_union;

// Create unions for A, B, and X
f_union unionA, unionB, unionX;

// Assign inputs and outputs to bitwise unions
always_comb begin
    bus.A = unionA.bits;
    bus.B = unionB.bits;
    unionX.bits = bus.Result;
end

initial
begin

    // Start with a static test
	unionA.f = -1.245;
	unionB.f = 2.753;
    #10;

    `ifdef DEBUGTB
        $display("Adding %e and %e resulted in %e, expected is %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
    `endif

    // Check results. If failing, end the simulation
    if ( unionX.f !== unionA.f + unionB.f)
    begin
        error++;
	$display("Adding %e and %e resulted in %e instead of %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
        $display("FP Adder failed static case. Test Failed");
        $finish;
    end

    do begin
        tests++;

        // Generate random (non-NAN/INF) values
        do  rawA = $urandom;  while (rawA[30:23] == 8'hFF);
        do  rawB = $urandom;  while (rawB[30:23] == 8'hFF);
        unionA.bits = rawA;
        unionB.bits = rawB;
            
        #10
        `ifdef DEBUGTB
            $display("Adding %e and %e resulted in %e, expected is %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
            $display("A: %b		B: %b		Act: %b		Ex: %b", unionA.bits, unionB.bits, unionX.bits, unionA.bits + unionB.bits );

        `endif
        //  Check results and report errors
        if ( unionX.f !== unionA.f + unionB.f)
        begin
            error++;
            $display("FP adder failed. Adding %e and %e resulted in %e instead of %e ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
            $display("A: %b		B: %b		Act: %b		Ex: %b", unionA.bits, unionB.bits, unionX.bits, unionA.bits + unionB.bits );
        end
    end
    while (tests <= (Tests >> 8) );    

    if (error)
	    $display("%d Errors found in FP adder test", error);
    else
	    $display("No errors found in FP adder test");
    $finish;
end
endmodule

