module top_m1;
timeunit 1ns;
timeprecision 1ns;
localparam time PERIOD = 10;
localparam int unsigned DWIDTH = 8;
localparam int unsigned AWIDTH = 5;
localparam bit DEBUG =1;
logic CLK;

memory_if #(DWIDTH, AWIDTH) intfc(.CLK);
memory_m #(DWIDTH, AWIDTH) memory(.clk(CLK), .intfc(intfc.mem));
memory_test_p #(DWIDTH, AWIDTH, DEBUG) memory_test(.clk(CLK), .intfc(intfc.test));

initial CLK = 0;
always #(PERIOD/2) CLK = ~CLK;
endmodule : top_m1
