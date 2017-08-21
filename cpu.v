module cpu(clk,btn,led);
	input clk;
	input[3:0] btn;
	output[3:0] led;
	
	wire [4:0] op;
	wire[2:0] rd_p,rs_p;
	wire[11:0] im;
	wire [3:0] nbtn;
	wire is_sorce_im;
	wire [23:0] dout;
	reg [7:0]addr=8'b00000000;
	assign nbtn=~btn;

	reg[23:0]register[5:0];//A,B,C,D,SP,BP;
	reg[23:0]out=24'b000000000000000000000000;
	reg c_flag=1'b0;
	reg[23:0] data_mem[23:0];
	integer i;
	initial begin
		for(i=1'b0;i<8'h1111;i=i+1)
			data_mem[i]=24'h0000;
	
	
		for(i=1'b0;i<6;i=i+1'b1)
			register[i]=1'b0;

	end
	
	rom memory(dout,addr);
	
	decoder decode(clk,dout,is_sorce_im,op,rd_p,rs_p,im);
			
	always @(posedge clk)begin
				case(op)
					5'b00000:begin //mov
						register[rd_p]<=register[rs_p];
					end
					5'b00001:begin //add
						if(is_sorce_im==1'b0)//reg+reg
							register[rd_p]<=register[rd_p]+register[rs_p];
						else//reg+im
							register[rd_p]<=register[rd_p]+im;
					end
					5'b00010:begin //sub
						register[rd_p]<=register[rd_p]-register[rs_p];
					end
					
					5'b00011:begin//load
						register[rd_p]<=data_mem[register[rs_p]];
					end
					5'b00100:begin//store
						data_mem[register[rd_p]]<=register[rs_p];
					end
					5'b00101:begin//putc
						//out<=register[rd_p];
						$display("%c",register[rs_p]);									
					end
					/*6'b000110:begin//exit
							;
					end
					*/
						5'b01000:begin//eq01					
						register[rd_p]<=(register[rd_p]==register[rs_p]);
					end
					5'b01001:begin//ne01					
						register[rd_p]<=(register[rd_p]!=register[rs_p]);
					end
					5'b01010:begin//lt01					
						register[rd_p]<=(register[rd_p]<register[rs_p]);
					end
					5'b01011:begin//gt01					
						register[rd_p]<=(register[rd_p]>register[rs_p]);
					end
					5'b01100:begin//le01					
						register[rd_p]<=(register[rd_p]<=register[rs_p]);
					end
					5'b01101:begin//ge01					
						register[rd_p]<=(register[rd_p]>=register[rs_p]);
					end
				
					5'b01110:begin//jeq
						if(register[rd_p]==register[rs_p])begin
							addr<=im;
						end
					end
					5'b01111:begin//jne
						if(register[rd_p]!=register[rs_p])begin
							addr<=im;
						end
					end
					5'b10000:begin//jlt
						if(register[rd_p]<register[rs_p])begin
							addr<=im;
						end
					end
					5'b10001:begin//jgt
						if(register[rd_p]>register[rs_p])begin
							addr<=im;
						end
					end

					5'b10010:begin//jle
						if(register[rd_p]<=register[rs_p])begin
							addr<=im;
						end
					end
					5'b10011:begin//jge
						if(register[rd_p]>=register[rs_p])begin
							addr<=im;
						end
					end
					5'b10100:begin//jmp
							addr<=im;
					end
					default:;
		endcase
		if(op<5'b01000)
			addr<=addr+1;
	end

endmodule 