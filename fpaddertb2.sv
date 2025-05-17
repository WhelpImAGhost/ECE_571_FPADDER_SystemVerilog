module top;
parameter Tests = 2 << 20;

shortreal fA, fB, fX;
bit [31:0] rawA, rawB, iA, iB, iX, iEx;

int error, tests;

fpbus bus();
FPAdder f1(bus);

always_comb begin
	iA = $shortrealtobits(fA);
	iB = $shortrealtobits(fB);
	iX = bus.Result;
	iEx = $shortrealtobits(fA + fB);
    bus.A = iA;
    bus.B = iB;
    fX = $bitstoshortreal(iX);
end

initial
begin

    fA = -1.245;
    fB = 2.753;
    #10;

    `ifdef DEBUGTB
        $display("Adding %e and %e resulted in %e, expected is %e ",
        fA, fB, fX, fA + fB);
	$display("A: %b		B: %b		Act: %b		Ex: %b", iA, iB, iX, iEx );	
    `endif

    if ( iX !== iEx)
    begin
        error++;
	    $display("Adding %e and %e resulted in %e instead of %e ", 
        fA, fB, fX, fA + fB);
        $display("FP Adder failed static case. Test Failed");
        $finish;
    end


    do begin
        tests++;

        // Generate random (non-NAN/INF) values
        do  rawA = $urandom;  while (rawA[30:23] == 8'hFF);
        do  rawB = $urandom;  while (rawB[30:23] == 8'hFF);
        fA = $bitstoshortreal(rawA);
        fB = $bitstoshortreal(rawB);
            
        #10
        `ifdef DEBUGTB
            $display("Adding %e and %e resulted in %e, expected is %e ", fA, fB, fX, fA + fB);
            

        `endif
        //  Check results and report errors
        if ( iX !== iEx)
        begin
            error++;
            $display("FP adder failed. Adding %e and %e resulted in %e instead of %e ", fA, fB, fX, fA + fB);
            
        end
    end
    while (tests <= (Tests >> 8) );  

    tests = 0;

        do begin
        tests++;

        // Generate random (non-NAN/INF) values
        rawA = $urandom;
        rawB = $urandom;
        fA = $bitstoshortreal(rawA);
        fB = $bitstoshortreal(rawB);
            
        #10
        `ifdef DEBUGTB
            $display("Adding %e and %e resulted in %e, expected is %e ", fA, fB, fX, fA + fB);

        `endif
        //  Check results and report errors
        if ( iX !== iEx)
        begin
            error++;
            $display("FP adder failed. Adding %e and %e resulted in %e instead of %e ", fA, fB, fX, fA + fB);
            
        end
    end
    while (tests <= Tests );  

    $finish;
end


final begin
    if (error)
	    $display("--- %d Errors found in FP adder test ---", error);
    else
	    $display("--- No errors found in FP adder test ---");
end


endmodule
