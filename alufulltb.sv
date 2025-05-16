//Full ALU Testbench Using All Prior Modules

module top();

    //Module Instantitations
    fpbus bus(.*);
    Mask mask(bus.mask);
    Aligment align(bus.align);
    ALU alu(bus.alu);

    int i;                                              //Loop Variable
    int Error;                                          //Error Counter      
    initial
    begin
        for (i = 0; i < 10000; i++)
        begin
            bus.A = $urandom_range(0, 32'hFFFFFFFF);    //Random 32-Bit Value
            bus.B = $urandom_range(0, 32'hFFFFFFFF);    //Random 32-Bit Value
            #1;                                         //Wait for all modules to process
            
        end

    end

endmodule