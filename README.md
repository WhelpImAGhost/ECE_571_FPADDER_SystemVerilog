# ECE 571 FPADDER SystemVerilog

## Description

This project represents a floating point adder, which implements the IEEE 754 floating point standard for 32 bits into SystemVerilog. Using functions such as an interface, always_ff and always_comb blocks, this program is dramatically simplified and has easier readability in comparison to the previous Verilog language tools. The overall adder was split into five modules, each with a respective testbench to test its functionality and correctness. A non-synthesizable reference module was made to test against the project, and is also included. 

These files were created, debugged, and verified using Siemens / Mentor QuestaSim. The modules may not compile or run properly when used with another system.


## Files and Directories

### Modules
All modules are listed in respective files in the main directory. The reference module is also in the main directory, known as [reference.sv](reference.sv)

### Test Benches
The tests for each submodule can be found in the folder [TestBenches](TestBenches). To run each test, compile the test module with the required modules, which can be seen within each file. Each test will also need the [interface](fpbus.sv) in order to function properly, including the reference module. The system wide test requires the variable **MOD** to be defined at compile time. For Mentor Questa, this can be achieved by adding **define+MOD** to the compilation command.



