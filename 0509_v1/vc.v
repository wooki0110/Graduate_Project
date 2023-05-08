`include "define.h" 
module vc ( 
        bdata,  
        send,   
        olck,   

        irdy_0, 
        irdy_1, 
        irdy_2, 
        irdy_3, 
        irdy_4, 
        ilck_0, 
        ilck_1, 
        ilck_2, 
        ilck_3, 
        ilck_4, 

        grt_0, 
        grt_1, 
        grt_2, 
        grt_3, 
        grt_4, 

        req,  
        port, 
        ovch, 

        clk, 
        rst_ 
);
parameter       ROUTERID= 0;
parameter       PCHID   = 0;
parameter       VCHID   = 0;

input   [`DATAW:0]      bdata;  
output                  send;   
output                  olck;   

input   [`VCH:0]        irdy_0; 
input   [`VCH:0]        irdy_1; 
input   [`VCH:0]        irdy_2; 
input   [`VCH:0]        irdy_3; 
input   [`VCH:0]        irdy_4; 
input   [`VCH:0]        ilck_0; 
input   [`VCH:0]        ilck_1; 
input   [`VCH:0]        ilck_2; 
input   [`VCH:0]        ilck_3; 
input   [`VCH:0]        ilck_4; 

input                   grt_0; 
input                   grt_1; 
input                   grt_2; 
input                   grt_3; 
input                   grt_4; 

output                  req;  
input   [`PORTW:0]      port; 
input   [`VCHW:0]       ovch; // vc안쓰므로 0

input   clk, rst_;            

// ilck, grt, irdy 3개가 전송해야할 다음 router의 VC 비어있는지 파악
reg     [1:0]           state;
wire    [`TYPEW:0]      btype;  //3bit
reg                     req;     /* Request signal */
wire                    ilck;    /* 1: Next VC is locked by others */
wire                    grt;	 /* 1: Output channel is allocated */
wire                    irdy;	 /* 1: Next VC can receive a flit  */ 
reg                     send;


/*
 * State machine, 3단계 구성(RC, VSA, ST)
 */
`define RC_STAGE      2'b00
`define VSA_STAGE     2'b01
`define ST_STAGE      2'b10

/*  
 * Input flit type 
 */ 
assign  btype   = bdata[`TYPE_MSB:`TYPE_LSB]; 

/*  
 * Packet-level arbitration , ilck는 해당 VC로 flit이 넘어가면 1로 바뀜, 조절은 outputc.v에서 virtual channel 상태 파악
 */ 
assign  ilck    = ( 
                   (port == 0 && ilck_0[ovch]) || 
                   (port == 1 && ilck_1[ovch]) || 
                   (port == 2 && ilck_2[ovch]) || 
                   (port == 3 && ilck_3[ovch]) || 
                   (port == 4 && ilck_4[ovch]) ); 

/*  
 * Flit-level transmission control , grt는 cb.v에서 조절, 역할은 outputchannel 할당
 * irdy는 VC가 flit을 받을 수 있는지 여부, outputc.v에서 상태 파악 후 할당해줌
 */ 
assign  grt     = ( 
                   (port == 0 && grt_0) || 
                   (port == 1 && grt_1) || 
                   (port == 2 && grt_2) || 
                   (port == 3 && grt_3) || 
                   (port == 4 && grt_4) ); 
assign  irdy    = ( 
                   (port == 0 && irdy_0[ovch]) || 
                   (port == 1 && irdy_1[ovch]) || 
                   (port == 2 && irdy_2[ovch]) || 
                   (port == 3 && irdy_3[ovch]) || 
                   (port == 4 && irdy_4[ovch]) ); 

assign  olck    = (state != `RC_STAGE); // VSA, ST 일때만 olck 켜짐(무슨 의미?)


/*
 * State transition control
 */
always @ (posedge clk) begin
	if (rst_ == `Enable_) begin // 초기 설정
		state	<= `RC_STAGE;
		send	<= `Disable;
		req	<= `Disable;
	end else begin
		case (state)

		/*
		 * State 1 : Routing computation, header라면 VSA로 이동시키고 req 1로 변경(즉, header제외 RC 동작 안함)
		 */
		`RC_STAGE: begin
			if (btype == `TYPE_HEAD ||
			    btype == `TYPE_HEADTAIL) begin
				state	<= `VSA_STAGE;
				send	<= `Disable;
				req	<= `Enable;
			end
		end

                /*
                 * State 2 : Virtual channel / switch allocation
                 * 결국 grt irdy 우선
                 */
                `VSA_STAGE: begin
			if (ilck == `Enable) begin
                        	/* Switch is locked (unable to start 
				   the arbitration) */
				req     <= `Disable;
			end if (grt == `Disable) begin
                        	/* Switch is not locked but it is not 
				   allocated */
				req     <= `Enable;
			end if (irdy == `Enable && grt == `Enable) begin
                        	/* Switch is allocated and it is free!  */
                                state   <= `ST_STAGE;
				send	<= `Enable;
				req     <= `Enable;
			end
                end

                /*
                 * State 3 : Switch Traversal, Tail이 되면 RC stage로 변환 
                 */
		`ST_STAGE: begin
			if (btype == `TYPE_HEADTAIL || 
			    btype == `TYPE_TAIL) begin
				state	<= `RC_STAGE;
				send	<= `Disable;
				req	<= `Disable;
			end
		end
		endcase
	end
end

endmodule
