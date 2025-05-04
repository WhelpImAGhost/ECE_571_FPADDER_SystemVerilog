module top;
parameter Tests = 4096;

logic [31:0] A, B, X;
shortreal floatA, floatB, floatX;
int error, tests;
bit [31:0] rawA, rawB;

typedef union {
       	shortreal f;
        logic [31:0] bits;
} f_union;

f_union unionA, unionB, unionX;

FPAdder f0 (unionA.bits, unionB.bits, unionX.bits);

initial
begin

	unionA.f = 1.245;
	unionB.f = 2.753;
    #10;

    if ( unionX.f !== unionA.f + unionB.f)
    begin
        error++;
        $display("FP Adder failed static case. Test Failed");
        $display("Adding %f and %f resulted in %f instead of %f ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
        $finish;
    end

    do begin
        tests++;


	do  rawA = $urandom;  while (rawA[30:23] == 8'hFF); // avoid Inf/NaN
	do  rawB = $urandom;  while (rawB[30:23] == 8'hFF);
	unionA.f = shortreal'(rawA);
	unionB.f = shortreal'(rawB);
        
	#10
        if ( unionX.f !== unionA.f + unionB.f)
        begin
            error++;
            $display("FP adder failed. Adding %f and %f resulted in %f instead of %f ", unionA.f, unionB.f, unionX.f, unionA.f + unionB.f);
	    $display("A: %b		B: %b		Act: %b		Ex: %b", unionA.bits, unionB.bits, unionX.bits, unionA.bits + unionB.bits );
        end
    end
    while (tests <= Tests);    

    if (error)
	    $display("%d Errors found in FP adder test", error);
    else
	    $display("No errors found in FP adder test");
    $finish;
end

endmodule

