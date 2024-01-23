interface memory_if #(parameter int unsigned DW = 8, parameter int unsigned AW = 5) (input logic CLK);
timeunit 1ns;
timeprecision 1ns;

logic [DW-1 : 0] data_out; // memory data out
logic [DW-1 : 0] data_in; // memory_test data in
logic [AW-1 : 0] addr;//memory_test address

logic write; // memory _test write
logic read; //memory_test read
clocking cb @(posedge CLK);
default input #1step output negedge; // o/p w.r.t to testbench will go into dut at negedge
input data_out;
output data_in, addr, read, write;
endclocking

task write_mem(input [AW-1 : 0] waddr, input [DW-1 : 0] wdata, input debug = 0);
cb.write <= 1; //use non-blocking assignment to cb signal
cb.read <= 0;
cb.addr <= waddr;
cb.data_in <= wdata;
@(cb); // clock delay

cb.write <= 0;
if(debug == 1)
$display("%t : write-address : %d data = %h", $time, waddr, wdata);
endtask

task read_mem(input [AW-1 : 0] raddr, input [DW-1 : 0] rdata, input debug = 0);
cb.write <= 0; //use non-blocking assignment to cb signal
cb.read <= 1;
cb.addr <= raddr;
//##1; // clock delay
@(cb);
cb.read <= 0;
@cb; // accomodate extra cycle delay for sampled data
rdata = cb.data_out;
if(debug == 1)
$display("%t : read-address : %d data = %h", $time, raddr, rdata);
endtask

modport mem(output data_out, input data_in, addr, write, read);
modport test(clocking cb, input data_out, output data_in, addr, write, read ,import write_mem, read_mem);
// yha correction ki h i.e made i/p ka o/p in above line

endinterface : memory_if

