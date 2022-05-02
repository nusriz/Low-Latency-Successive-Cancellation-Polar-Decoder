`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module hfadd(x,y,s,c);
input x,y;
output s,c;
assign s = x^y;
assign c = x&y;
endmodule

/////////////////////////////////////////////////////////////////////////////////

module fladd(x,y,cin ,s,cout);
input x,y,cin;
output s,cout;
assign s = x^y^cin;
assign cout  = (x&y)|(cin&(x^y)); 
endmodule


//////////////////////////////////////////////////////////////////////////////////

module n_bit_adder(in1,in2,answer);
reg cp = 1'b1;
parameter bt = 16;


function automatic [bt-1:0]comp;

input [bt-1:0] in;
comp = ~in + (cp<<bt-1)+ 1'b1;

endfunction


input [bt-1:0]in1,in2;
reg [bt-1:0] input1,input2;
output  reg [bt-1:0] answer;
wire [bt-1:0] carry,tempz;


always@ (in1,in2)
	begin
		if(in1[bt-1]==1)
		input1 = comp(in1);
		else 
		input1 = in1;
		if(in2[bt-1]==1)
		input2 = comp(in2);
		else
		input2 = in2;
	end	
genvar i;
generate
for(i=0;i<bt;i=i+1)
	begin: h
	if(i==0)
	hfadd f(input1[0],input2[0],tempz[0],carry[0]);
	else
	fladd f(input1[i],input2[i],carry[i-1],tempz[i],carry[i]);
	end
endgenerate

always@ (tempz)
begin
if (tempz[bt-1]==1)
	answer = comp(tempz);
	else
	answer = tempz;

end
endmodule

///////////////////////////////////////////////////////////////////////////////
module f(input1, input2,out);
parameter bt = 16;
input [bt-1:0] input1,input2;
output reg[bt-1:0] out;
reg [bt-1:0] temp1,temp2;
wire [bt-1:0] s;
reg cp = 1'b1;

always@ *
begin
 temp1 = input1&(~(cp<<bt-1));
 temp1[bt-1] = ~temp1[bt-1];
 temp2 = input2&(~(cp<<bt-1));
end
n_bit_adder addr(temp1,temp2,s);
always@(s)
begin
if(s[bt-1]==0)
begin
out = temp1;
 out[bt-1]= input1[bt-1]^input2[bt-1];
end
else
begin
out = temp2;
 out[bt-1]= input1[bt-1]^input2[bt-1];
end
end

endmodule

///////////////////////////////////////////////////////////////////////////////





module g(input1,input2,sig,u1);
parameter bt = 16;
input [bt-1:0] input1,input2;
input sig;
output wire [bt-1:0] u1;
reg [bt-1:0] temp1;
always@(*)
begin
if(sig==1)
	if(input1!=0)
		begin
		temp1 = input1;
		temp1[bt-1] = ~input1[bt-1];
		end
	else
		temp1 = 0;
else
      temp1 = input1;		
end
n_bit_adder adr(temp1,input2,u1);
endmodule


//////////////////////////////////////////////////////////////////////////////////

module mainmod(clk,b,c,d,e,b1,c1,d1,e1,u1,u2,u3,u4,u5,u6,u7,u8);

parameter bt = 16;
parameter m = 8;
input clk;
wire [127:0] a;
input [15:0]  b,c,d,e,b1,c1,d1,e1;
assign a = {b,c,d,e,b1,c1,d1,e1}; 
output reg u1,u2,u3,u4,u5,u6, u7;
output wire u8;
wire [bt-1:0] func [0:m-1];
reg [bt-1:0] temp [ 0:m-1];
reg [bt-1:0] tempf [ 0:(m-1)/2];
reg [bt-1:0] tempg [ 0:(m-1)/2];
reg sig [0:(m-1)/2];
reg [3:0] stg = 4'b0001; 
assign u8 = func[4][bt-1];


f f1(temp[0],temp[4],func[0]);
f f2(temp[1],temp[5],func[1]);
f f3(temp[2],temp[6],func[2]);
f f4(temp[3],temp[7],func[3]);
g g1(temp[0],temp[4],sig[0],func[4]);
g g2(temp[1],temp[5],sig[1],func[5]);
g g3(temp[2],temp[6],sig[2],func[6]);
g g4(temp[3],temp[7],sig[3],func[7]);
always@(posedge clk)
begin
	case ( stg)
		4'b0001: 
				begin	
					temp[0] = a[127:112];
					temp[1] = a[111:96];
					temp[2] = a[95:80];
					temp[3] = a[79:64];
					temp[4] = a[63:48];
					temp[5] = a[47:32];
					temp[6] = a[31:16];
					temp[7] = a[15:0];
					
				
				end	
		4'b0010:
				begin	
				   tempf[0] = func[0];
					tempf[1] = func[1];
					tempf[2] = func[2];
					tempf[3] = func[3];
					temp[2] = func[0];
					temp[6] = func[2];
					temp[3] = func[1];
					temp[7] = func[3];
				
				end
		4'b0011:
				begin	
					temp[1] = func[2];
					temp[5] = func[3];
					
					
					
				end
		4'b0100:
				begin
				
					u1 = func[1][bt-1];
					temp[0] = func[2];
					temp[4] = func[3];
					sig[0] = func[1][bt-1];
					
					
				end
		4'b0101:
				begin
					
					
					u2 = func[4][bt-1];
					temp[0] = tempf[0];
					temp[4] = tempf[2];
					temp[1] = tempf[1];
					temp[5] = tempf[3];
					sig[0] = u1^func[4][bt-1];
					sig[1] = func[4][bt-1];
					
				end
		4'b0110:
				begin
					tempg[0] = func[4];
					tempg[1] = func[5];
					temp[0] = func[4];
					temp[4] = func[5];
					
				end
		4'b0111:
				begin
					u3 = func[0][bt-1];
					temp[2] = tempg[0];
					temp[6] = tempg[1];
					sig[2] = u3;
				
				end
		4'b1000:
				begin
					u4 = func[6][bt-1];
					temp[0] = a[127:112];
					temp[1] = a[111:96];
					temp[2] = a[95:80];
					temp[3] = a[79:64];
					temp[4] = a[63:48];
					temp[5] = a[47:32];
					temp[6] = a[31:16];
					temp[7] = a[15:0];
					sig[0] = u1^u2^u3^func[6][bt-1];
					sig[1] = u2^func[6][bt-1];
					sig[2] = u3^func[6][bt-1];
					sig[3] = func[6][bt-1];
				end
		4'b1001:
				begin 
					tempg[0] = func[4];
					tempg[1] = func[5];
					tempg[2] = func[6];
					tempg[3] = func[7];
					temp[2] = func[4];
					temp[6] = func[6];
					temp[3] = func[5];
					temp[7] = func[7];
				end
		4'b1010:
				begin
					temp[1] = func[2];
					temp[5] = func[3];
				end
		4'b1011:
				begin
					u5 = func[1][bt-1];
					temp[0] = func[2];
					temp[4] = func[3];
					sig[0] = func[1][bt-1];
				end	
		4'b1100:
				begin
					u6 = func[4][bt-1];
					temp[1] = tempg[0];
					temp[5] = tempg[2];
					temp[2] = tempg[1];
					temp[6] = tempg[3];
					sig[1] = u5^func[4][bt-1];
					sig[2] = func[4][bt-1];
				end
		4'b1101:		
				begin
					
					tempg[0] = func[5];
					tempg[1] = func[6];
					temp[3] = func[5];
					temp[7] = func[6];
				
				end
		4'b1110:
				begin
					u7 = func[3][bt-1];
					temp[0] = tempg[0];
					temp[4] = tempg[1];
					sig[0] = func[3][bt-1];
		end	
			default: ;
	endcase	
		stg = stg + 1'b1;
end
endmodule
