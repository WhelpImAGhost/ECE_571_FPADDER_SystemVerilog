module top;
parameter T = 25;
parameter FILENAME = "test-vals"

shortreal fA, fB, fX;
bit [31:0] rawA, rawB, iA, iB, iX, iEx;

longint error, tests, Tests;
int fd;


fpadder Adder(iA, iB, iX);


always_comb begin
	iA = $shortrealtobits(fA);
	iB = $shortrealtobits(fB);
	iEx = $shortrealtobits(fA + fB);
    fX = $bitstoshortreal(iX);
end

initial
begin

    fd = $fopen(FILENAME, "r");

    if (fd) $display("Test file %s opened successfully", FILENAME);
    else begin
        $display("File %s could not be opened. Constrained tests will be skipped", FILENAME);
    end

    Tests = 1 << T;
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
	$display("Passed single case");


    if (fd) begin
        // Test bulk static cases from file
        while(!$feof(fd)) begin
            if  (($fscanf(fd, "%h, %h", iA, iB) ) < 1) continue;
            checkResult();
        end
        if (error > 0) $finish;
        $display("Passed static cases");
    end

    do begin
        tests++;

        // Generate random (non-NAN/INF) values
        do  rawA = $urandom;  while (rawA[30:23] == 8'hFF);
        do  rawB = $urandom;  while (rawB[30:23] == 8'hFF);
        fA = $bitstoshortreal(rawA);
        fB = $bitstoshortreal(rawB);

            `ifdef DEBUGTB
                $display("Adding %e and %e resulted in %e, expected is %e ", fA, fB, fX, fA + fB);
            `endif
            checkResult();

    end
    while (tests <= (Tests) );  
	$display("Finished random normals and subnormals tests");

    tests = 0;

        do begin
        tests++;

        // Generate random (non-NAN/INF) values
        rawA = $urandom;
        rawB = $urandom;
        fA = $bitstoshortreal(rawA);
        fB = $bitstoshortreal(rawB);

 

        `ifdef DEBUGTB
            $display("Adding %e and %e resulted in %e, expected is %e ", fA, fB, fX, fA + fB);
        `endif

        checkResult();

    end
    while (tests <= Tests );  
	$display("Finished full random test");
    $finish;
end


final begin
    if (error)
	    $display("--- %d Errors found in FP adder test ---", error);
    else
	    $display("--- No errors found in FP adder test ---");
end


task automatic checkResult;
begin
    #10;
    
    `ifdef DEBUGTB
        $display("Adding %e and %e resulted in %e, expected is %e ",
        fA, fB, fX, fA + fB);
	$display("A: %b		B: %b		Act: %b		Ex: %b", iA, iB, iX, iEx );	
    `endif
    
    
    if ( iX !== iEx && !(isNaN(iX) && isNaN(iEx) ))
    begin
        error++;
        $display("FP adder failed. Adding %e and %e resulted in %e instead of %e ", fA, fB, fX, fA + fB);
    end
end
endtask

function automatic bit isNaN(input logic [31:0] val);
    return (val[30:23] == 8'hFF) && (val[22:0] != 0);
endfunction


endmodule
