`include "define.h" 
module rtcomp (
	idata,
	port,
	ovch,
	foab_en,
	odata,

	my_xpos,
	my_ypos,

	clk,
	rst_
);
input	[`DATAW:0]	idata;

output	[`PORTW:0]	port;
output	[`VCHW:0]	ovch;
output				foab_en;

input	[`ARRAYW:0]	my_xpos;
input	[`ARRAYW:0]	my_ypos;

input	clk;
input	rst_;

wire	[`PORTW:0]	port0;
reg	[`PORTW:0]	port1;
wire	[`VCHW:0]	ovch0;
reg	[`VCHW:0]	ovch1;

wire	[`ARRAYW:0]	dst_xpos;
wire	[`ARRAYW:0]	dst_ypos;

always @ (posedge clk) begin
	if (rst_ == `Enable_) begin 
		dst_xpos	<= 0;
		dst_ypos	<= 0;
	end 
	else if (idata[`UM_TYPE] == 0) begin
		dst_xpos	<= idata[`DST_MSB:`DST_LSB] % 5;
		dst_ypos	<= idata[`DST_MSB:`DST_LSB] / 5;
	end
	else if (idata[`MDST_LSB] == 1) begin
		dst_xpos	<= 0;
		dst_xpos	<= 0;
		idata[`MDST_LSB]	<= 0;
	end
	else if (idata[`MDST_LSB + 1] == 1) begin
		dst_xpos 	<= 0;
		dst_ypos	<= 1;
		idata[`MDST_LSB + 1]	<= 0;
	end
	else if (idata[`MDST_LSB + 2] == 1) begin
		dst_xpos 	<= 0;
		dst_ypos	<= 2;
		idata[`MDST_LSB + 2]	<= 0;
	end
	else if (idata[`MDST_LSB + 3] == 1) begin
		dst_xpos 	<= 0;
		dst_ypos	<= 3;
		idata[`MDST_LSB + 3]	<= 0;
	end
	else if (idata[`MDST_LSB + 4] == 1) begin
		dst_xpos 	<= 0;
		dst_ypos	<= 4;
		idata[`MDST_LSB + 4]	<= 0;
	end
	else if (idata[`MDST_LSB + 5] == 1) begin
		dst_xpos 	<= 1;
		dst_ypos	<= 0;
		idata[`MDST_LSB + 5]	<= 0;
	end
	else if (idata[`MDST_LSB + 6] == 1) begin
		dst_xpos 	<= 1;
		dst_ypos	<= 1;
		idata[`MDST_LSB + 6]	<= 0;
	end
	else if (idata[`MDST_LSB + 7] == 1) begin
		dst_xpos 	<= 1;
		dst_ypos	<= 2;
		idata[`MDST_LSB + 7]	<= 0;
	end
	else if (idata[`MDST_LSB + 8] == 1) begin
		dst_xpos 	<= 1;
		dst_ypos	<= 3;
		idata[`MDST_LSB + 8]	<= 0;
	end
	else if (idata[`MDST_LSB + 9] == 1) begin
		dst_xpos 	<= 1;
		dst_ypos	<= 4;
		idata[`MDST_LSB + 9]	<= 0;
	end
	else if (idata[`MDST_LSB + 10] == 1) begin
		dst_xpos 	<= 2;
		dst_ypos	<= 0;
		idata[`MDST_LSB + 10]	<= 0;
	end
	else if (idata[`MDST_LSB + 11] == 1) begin
		dst_xpos 	<= 2;
		dst_ypos	<= 1;
		idata[`MDST_LSB + 11]	<= 0;
	end
	else if (idata[`MDST_LSB + 12] == 1) begin
		dst_xpos 	<= 2;
		dst_ypos	<= 2;
		idata[`MDST_LSB + 12]	<= 0;
	end
	else if (idata[`MDST_LSB + 13] == 1) begin
		dst_xpos 	<= 2;
		dst_ypos	<= 3;
		idata[`MDST_LSB + 13]	<= 0;
	end
	else if (idata[`MDST_LSB + 14] == 1) begin
		dst_xpos 	<= 2;
		dst_ypos	<= 4;
		idata[`MDST_LSB + 14]	<= 0;
	end
	else if (idata[`MDST_LSB + 15] == 1) begin
		dst_xpos 	<= 3;
		dst_ypos	<= 0;
		idata[`MDST_LSB + 15]	<= 0;
	end
	else if (idata[`MDST_LSB + 16] == 1) begin
		dst_xpos 	<= 3;
		dst_ypos	<= 1;
		idata[`MDST_LSB + 16]	<= 0;
	end
	else if (idata[`MDST_LSB + 17] == 1) begin
		dst_xpos 	<= 3;
		dst_ypos	<= 2;
		idata[`MDST_LSB + 17]	<= 0;
	end
	else if (idata[`MDST_LSB + 18] == 1) begin
		dst_xpos 	<= 3;
		dst_ypos	<= 3;
		idata[`MDST_LSB + 18]	<= 0;
	end
	else if (idata[`MDST_LSB + 19] == 1) begin
		dst_xpos 	<= 3;
		dst_ypos	<= 4;
		idata[`MDST_LSB + 19]	<= 0;
	end
	else begin
		dst_xpos 	<= dst_xpos;
		dst_ypos	<= dst_ypos;
	end
end

assign	foab_en	= idata[`UM_TYPE] ? 1 : 0;
assign	port	= en ? port0 : port1;
assign	ovch	= en ? ovch0 : ovch1; 
assign	odata	= idata

always @ (posedge clk) begin
	if (rst_ == `Enable_) begin 
		port1	<= 0;
		ovch1	<= 0;
	end else if (en) begin
		port1	<= port0;
		ovch1	<= ovch0;
	end
end

assign	port0	= ( dst_xpos == my_xpos && dst_ypos == my_ypos ) ? 4 :
                  ( dst_xpos > my_xpos ) ? 1 :
                  ( dst_xpos < my_xpos ) ? 3 :
                  ( dst_ypos > my_ypos ) ? 2 : 0;

/* The same virtual channel is used. */
assign ovch0	= ivch;
endmodule
