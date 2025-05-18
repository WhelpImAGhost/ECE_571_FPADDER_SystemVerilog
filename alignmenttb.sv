//Module to Test FPAdder Alignment Function
module top;

    int Error;

    fpbus bus (.*);
    Mask M(.bus(bus.mask));
    Alignment A1(.bus(bus.align));

    initial
    begin
        repeat (2 << 20)
        begin
            bus.A = $random;
            bus.B = $random;
            #10;
            `ifdef DEBUGTB
	            $display("\n\nA: %h	B: %h", bus.A, bus.B);
		        $display("Af: %e	Bf: %e", $bitstoshortreal(bus.A), $bitstoshortreal(bus.B));
	            $display("Aex: %h (%d)\nBex: %h (%d)", bus.exponentA, bus.exponentA, bus.exponentB, bus.exponentB);
	            $display("AM: %h\nBM: %h", bus.mantissaA, bus.mantissaB);
            `endif
            // Special Cases: Infinity or NaN
            if (bus.exponentA == 8'hFF || bus.exponentB == 8'hFF)
            begin
                //Checking for Incorrect Exponent Output
                if (bus.exponentOut !== 8'hFF)
                begin
                    Error++;
                    $display("Expected exponentOut: 8'hFF, but Received: %h", bus.exponentOut);
                    `ifdef DEBUGTB
                        $stop;
                    `endif
                end
                //Case: Both A and B are +/- Infinity or NaN
                if (bus.exponentA == 8'hFF && bus.exponentB == 8'hFF)
                begin
                    if (bus.alignedMantissaA !== {1'b0, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b0, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b0, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b0, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case: A is +/- Infinity or NaN
                else if (bus.exponentA == 8'hFF)
                begin
                    if (bus.alignedMantissaA !== {1'b0, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b0, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case: B is +/- Infinity or NaN
                else if (bus.exponentB == 8'hFF)
                begin
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b0, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b0, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
            end
            //Special Cases: Zero or Subnormal
            else if (bus.exponentA == 0 || bus.exponentB == 0)
            begin
                //Case 1: Both A and B are +/- Zero or Subnormal
                if (bus.exponentA == 0 && bus.exponentB == 0)
                begin
                    if (bus.exponentOut !== 8'h00)
                    begin
                        Error++;
                        $display("Expected exponentOut: 8'h00, but Received: %h", bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b0, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b0, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b0, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b0, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case 2: A is +/- Zero or Subnormal
                else if (bus.exponentA == 0)
                begin
                    if (bus.exponentOut !== bus.exponentB)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentB, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b0, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b0, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case 3: B is +/- Zero or Subnormal
                else if (bus.exponentB == 0)
                begin
                    if (bus.exponentOut !== bus.exponentA)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentA, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b0, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b0, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
            end
            //Normal Floating-Point Numbers
            else
            begin
                if (bus.exponentA > bus.exponentB)
                begin
                    if (bus.exponentOut !== bus.exponentA)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentA, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== ({1'b1, bus.mantissaB} >> (bus.exponentA - bus.exponentB)))
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", 
                                 ({1'b1, bus.mantissaB} >> (bus.exponentA - bus.exponentB)), bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                else if (bus.exponentB > bus.exponentA)
                begin
                    if (bus.exponentOut !== bus.exponentB)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentB, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== ({1'b1, bus.mantissaA} >> (bus.exponentB - bus.exponentA)))
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", 
                                ({1'b1, bus.mantissaA} >> (bus.exponentB - bus.exponentA)), bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                else
                begin
                    if (bus.exponentOut !== bus.exponentA)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentA, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
            end
        end
        $display("Simulation finished with %d %s\n", Error, (Error == 1 ? "Error" : "Errors"));
        $finish;
    end
endmodule