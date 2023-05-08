`include "define.h" 
module rtcomp (
	addr,
	ivch,
	en,
	port,
	ovch,

	my_xpos,
	my_ypos,

	clk,
	rst_
);
input	[`ENTRYW:0]	addr;
input	[`ENTRYW:0]	ivch;
input			en;
output	[`PORTW:0]	port;
output	[`VCHW:0]	ovch;

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
wire	[`ARRAYW:0]	delta_x1;	/* For torus */
wire	[`ARRAYW:0]	delta_x3;	/* For torus */

assign	dst_xpos= addr[`DSTX_MSB:`DSTX_LSB]; //dst각 x,y 분리하여 할당
assign	dst_ypos= addr[`DSTY_MSB:`DSTY_LSB];

assign	port	= en ? port0 : port1; //header라면 port0, 아니라면 port1
assign	ovch	= en ? ovch0 : ovch1; //여기는 어차피 0(VC사용 안한다면)

always @ (posedge clk) begin
	if (rst_ == `Enable_) begin //rst_가 0이라면 port1은 0
		port1	<= 0;
		ovch1	<= 0;
	end else if (en) begin //header신호 들어오면 port0의 값이 port1로 들어감
		port1	<= port0;
		ovch1	<= ovch0;
	end
end
// port0 조절부, 어느 port를 선택해야하는가를 선택해줌(destination 위치에 따라 가는것 같음)
// x,y가 같으면 4번 port, x가 현재 보다 크면 1번 port(동쪽), x가 현재 보다 작으면 3번 port(서쪽), y 구별(남쪽 2, 북쪽 0)
// x먼저 검토하므로 xy DOR 방식임
assign	port0	= ( dst_xpos == my_xpos && dst_ypos == my_ypos ) ? 4 :
                  ( dst_xpos > my_xpos ) ? 1 :
                  ( dst_xpos < my_xpos ) ? 3 :
                  ( dst_ypos > my_ypos ) ? 2 : 0;
/* The same virtual channel is used. */
assign ovch0	= ivch;
endmodule
