module memory_m #(parameter int unsigned DW = 8, parameter int unsigned AW = 5)(interface intfc, input logic clk);// data width & address width
timeunit 1ns;
timeprecision 1ns;
logic[DW-1 : 0] mem[2**AW]; // DW packed by 2**AW unpacked
always_ff @(posedge clk iff(intfc.write && !intfc.read))
mem[intfc.addr] <= intfc.data_in;
always_ff @(posedge clk iff(intfc.read && !intfc.write))
intfc.data_out<= mem[intfc.addr];
endmodule : memory_m
