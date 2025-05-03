module top;
parameter Tests = 4096;

logic [31:0] A, B, X;
short real floatA, floatB, floatX;
int error, tests;

FPAdder f0 (A, B, X);

assign A = floatA;
assign B = floatB;
assign floatX = X;

initial
begin

    floatA = 1.25;
    floatB = 2.75;

    #10;

    if ( floatX !== floatA + floatB)
    begin
        error++;
        $display("FP Adder failed static case. Test Failed");
        $finish;
    end

end

always_comb begin

    do begin
        tests++

        floatA = $urandom;
        floatB = $urandom;

        #10
        if ( floatX !== floatA + floatB)
        begin
            error++;
            $display("FP adder failed. Adding %f and %f resulted in %f instead of %f ", floatA, floatB, floatX, floatA + floatB);
        end
    end
    while (tests <= Tests);    
end

endmodule;

