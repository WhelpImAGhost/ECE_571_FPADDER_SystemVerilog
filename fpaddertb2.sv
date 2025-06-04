module top;
parameter T = 25;

shortreal fA, fB, fX;
bit [31:0] rawA, rawB, iA, iB, iX, iEx;

longint error, tests, Tests;

bit [31:0] static_pair[25][2] = '{
    // Normal + Normal = Normal : 1.5 + 2.5
    '{32'h3FC00000, 32'h40200000}, 
    
    // Normal + Normal w/ Carry = Normal : ~0.9999999 + ~1.0000001
    '{32'h3F7FFFFF, 32'h3F800001}, 
    
    // Normal + Normal Overflow = Infinity : max normal + max normal
    '{32'h7F7FFFFF, 32'h7F7FFFFF}, 
    
    // Normal + Normal Underflow = Zero : smallest normal + smallest normal negative
    '{32'h00800001, 32'h80800001}, 
    
    // Normal + Normal Underflow = Subnormal : smallest normal + tiny negative subnormal
    '{32'h00800000, 32'h80800001}, 
    
    // Normal + Subnormal = Subnormal : smallest normal + smallest positive subnormal
    '{32'h00800000, 32'h00000001}, 
    
    // Normal + Subnormal = Normal : 1.0 + small positive subnormal
    '{32'h3F800000, 32'h00000002}, 
    
    // Zero + Zero = Zero : +0 + +0
    '{32'h00000000, 32'h00000000}, 
    
    // Zero + Normal = Normal : +0 + 1.0
    '{32'h00000000, 32'h3F800000}, 
    
    // Zero + Subnormal = Subnormal : +0 + smallest positive subnormal
    '{32'h00000000, 32'h00000001}, 
    
    // Inf + Inf (Same Signs) = Inf : +Inf + +Inf
    '{32'h7F800000, 32'h7F800000}, 
    
    // Inf + Inf (Different Signs) = NaN : +Inf + -Inf
    '{32'h7F800000, 32'hFF800000}, 
    
    // Inf + Norm/Sub/Zero = Inf : +Inf + 1.0
    '{32'h7F800000, 32'h3F800000}, 
    
    // NaN + Anything = NaN : NaN + 1.0
    '{32'h7FC00001, 32'h3F800000}, 
    
    // Exact Opposites = Zero : +1.0 + -1.0
    '{32'h3F800000, 32'hBF800000}, 
    
    // Rounding: Round to nearest, tie to even : 1.5 + 1.5
    '{32'h3FC00000, 32'h3FC00000}, 
    
    // Rounding: close values to test rounding : just under 1.0 + just over 1.0
    '{32'h3F7FFFFF, 32'h3F800001}, 
    
    // Transition subnormal → normal : largest subnormal + smallest normal
    '{32'h007FFFFF, 32'h00800000}, 
    
    // Opposite signs (not exact opposites) : 1.5 + -1.0
    '{32'h3FC00000, 32'hBF800000}, 
    
    // Zero sign handling: +0 + -0
    '{32'h00000000, 32'h80000000}, 
    
    // Large magnitude difference: ~1e30 + ~1e-30
    '{32'h5E2D6E8B, 32'h2E6D415A}, 
    
    // Overflow max finite vs large finite causes Inf
    '{32'h7F7FFFFF, 32'h7F000000}, 
    
    // Exponent difference 1: 1.0 + 0.5
    '{32'h3F800000, 32'h3F000000}, 
    
    // Exponent difference 2: 1.0 + 0.25
    '{32'h3F800000, 32'h3E800000}, 
    
    // Exponent difference 3: 1.0 + 0.125
    '{32'h3F800000, 32'h3E000000}
};






    fpadder Adder(iA, iB, iX);


always_comb begin
	iA = $shortrealtobits(fA);
	iB = $shortrealtobits(fB);
	iEx = $shortrealtobits(fA + fB);
    fX = $bitstoshortreal(iX);
end

initial
begin

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
    // Test bulk static cases
    foreach (static_pair[x]) begin

        fA = $bitstoshortreal(static_pair[x][0]);
        fB = $bitstoshortreal(static_pair[x][1]);
        checkResult();
        if (error > 0) $finish;

    end
	$display("Passed static cases");

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
    while (tests <= (1 << 20) );  
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
