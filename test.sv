program memory_test_p #(parameter int unsigned DW = 8, parameter int unsigned AW = 5, parameter bit debug = 0)(interface intfc, input logic clk);  //DW = data width and AW = address width
timeunit 1ns;
timeprecision 1ns;
//class declaration inside program block

bit flag ; // taken according to problem given
class memrand_c;
randc logic[AW-1 : 0]addr;
rand logic[DW-1 : 0] data;
constraint c1{
// incomment one of these constraint to see effect of constraints
//data dist{[8'h41 : 8'h5a] := 4, [8'h61 : 8'h7a] := 1}; // 1
//data dist{[8'h01 : 8'h40] := 6, [8'h81 : 8'h9a] := 5}; // 2 changed weight, address range
// if(addr < (1<<(AW-1))) -> data <= 8'b5A;
if(addr < (1 <<(AW-1)))  data <= 8'h5a;
//if ((addr >= (1<<(AW-1))) -> data >= 8'h61;) //3
}

function new(input logic [AW-1 : 0] a, input logic[DW - 1 :0]d);
addr = a;
data = d;
endfunction endclass

function void printstatus(input int unsigned status);
$display("memory test %s with %0d errors", status ? "failed":"passed", status);
if(status != 0) $finish;
endfunction

initial begin
logic [AW-1 :0] addr;
logic [DW-1 : 0] data_w, data_r, data_e;
int unsigned errors;
memrand_c memrand;
$timeformat(-9, 1,"ns", 9);
@(intfc.cb); // sync. to interface clocking
$display("clearing the memory");
errors = 0;
for (int unsigned i = 0; i <= 2**AW-1 ; ++i)
  intfc.write_mem(i,0,0);
for (int unsigned i = 0; i <= 2**AW-1 ; i= i+1)
begin
intfc.read_mem(i, data_r, 0);
if (data_r !== 0)
++errors;
end

printstatus(errors);
$display("test data = random");
errors = 0;
memrand = new(0,0); //changed range
//memrand = new(8,5);
memrand.srandom(0);// seeding the object with value '0'
// srandom gives signed random values
for(int unsigned i =0 ; i<2**AW-1; ++i) begin
if(!memrand.randomize())begin
$display("randomize memrand failed");
$finish(0);
end
addr = memrand.addr;
data_w = memrand.data;
intfc.write_mem(addr, data_w, debug);
end
memrand.srandom(0); // again seeding the object with value "0"
for(int unsigned i = 0; i<= 2**AW-1; i++)
begin
if(!memrand.randomize()) begin
$display("randomization memrand failed");
$finish(0);
end
addr = memrand.addr;
data_e = memrand.data;
intfc.read_mem(addr, data_r,debug);
if(data_r !== data_e)
++errors;
end
printstatus(errors);
$finish(0);
end
// covergroup declaration specific to the problem given

covergroup cg @(posedge clk);
address : coverpoint intfc.addr iff ( flag == 1 && intfc.write) { option.auto_bin_max = 32;}
data_in : coverpoint intfc.data_in iff ( flag == 1 && intfc.write) { option.auto_bin_max = 256;}
data_in_3_bins : coverpoint intfc.data_in iff ( flag == 1 && intfc.write) { bins low = {[0:127]}; bins high = {[128:255]}; bins a = default;}  
endgroup

cg w_handle = new(); // creating the covergroup is necessary

endprogram : memory_test_p

