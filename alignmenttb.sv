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
            bus.A = $urandom;
            bus.B = $urandom;
            #10;
            // Special Cases: NaN, Inf, Zero
            if (bus.ANaN  || bus.BNaN || bus.Ainf || bus.Binf || bus.Azero || bus.Bzero )
            begin
                continue;
            end
            //Special Cases:  Subnormal
            else if (bus.Asub || bus.Bsub)
            begin
                //Case 1: Both A and B are +/- Zero or Subnormal
                if (bus.Asub && bus.Bsub)
                begin
                    if (bus.exponentOut !== 8'h00)
                    begin
                        Error++;
                        $display("Expected exponentOut: 8'h00, but Received: %h", bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !==  {bus.mantissaA, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {bus.mantissaA, 8'b0}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !==  {bus.mantissaB, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {bus.mantissaB, 8'b0}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case 2: A is +/- Zero or Subnormal
                else if (bus.Asub)
                begin
                    if (bus.exponentOut !== bus.exponentB)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentB, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b0, bus.mantissaA, 8'b0} >> bus.exponentB - 1)
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b0, bus.mantissaA, 8'b0} >> bus.exponentB - 1, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB, 8'b0}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                end
                //Case 3: B is +/- Zero or Subnormal
                else if (bus.Bsub)
                begin
                    if (bus.exponentOut !== bus.exponentA)
                    begin
                        Error++;
                        $display("Expected exponentOut: %h, but Received: %h", bus.exponentA, bus.exponentOut);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA, 8'b0}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b0, bus.mantissaB, 8'b0} >> bus.exponentA - 1)
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b0, bus.mantissaB, 8'b0} >> bus.exponentA - 1, bus.alignedMantissaB);
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
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA, 8'b0}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== ({1'b1, bus.mantissaB, 8'b0} >> (bus.exponentA - bus.exponentB)))
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", 
                                 ({1'b1, bus.mantissaB, 8'b0} >> (bus.exponentA - bus.exponentB)), bus.alignedMantissaB);
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
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB, 8'b0}, bus.alignedMantissaB);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaA !== ({1'b1, bus.mantissaA, 8'b0} >> (bus.exponentB - bus.exponentA)))
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", 
                                ({1'b1, bus.mantissaA, 8'b0} >> (bus.exponentB - bus.exponentA)), bus.alignedMantissaA);
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
                    if (bus.alignedMantissaA !== {1'b1, bus.mantissaA, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaA: %h, but Received: %h", {1'b1, bus.mantissaA, 8'b0}, bus.alignedMantissaA);
                        `ifdef DEBUGTB
                            $stop;
                        `endif
                    end
                    if (bus.alignedMantissaB !== {1'b1, bus.mantissaB, 8'b0})
                    begin
                        Error++;
                        $display("Expected alignedMantissaB: %h, but Received: %h", {1'b1, bus.mantissaB, 8'b0}, bus.alignedMantissaB);
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
