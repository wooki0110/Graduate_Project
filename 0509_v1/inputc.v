`include "define.h" 
module inputc ( 
        idata,  
        ivalid, 
        ivch,   
        oack,   
        ordy,   
        olck,   

        odata,  
        ovalid, 
        ovch,   

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

        port,  
        req,   

        my_xpos, 
        my_ypos, 

        clk, 
        rst_ 
);
parameter       ROUTERID= 0;
parameter       PCHID   = 0;

input   [`DATAW:0]      idata;  
input                   ivalid; 
input   [`VCHW:0]       ivch;   
output  [`VCH:0]        oack;   // send 신호
output  [`VCH:0]        ordy;   // 한 packet이 fifo에 들어갈 수 있는지를 파악하고 1이면 packet 전송 가능
output  [`VCH:0]        olck;   // VSA, ST 단계임을 알려주는 신호

output  [`DATAW:0]      odata;  // 나가는 데이터
output                  ovalid; // send가 활성화 되면 ovaild 1로 변환됨
output  [`VCHW:0]       ovch;   // 나가는 vch 어디인가?

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

output  [`PORTW:0]      port;   
output                  req;    

input   [`ARRAYW:0]     my_xpos;
input   [`ARRAYW:0]     my_ypos;

input   clk, rst_;              

wire    [`DATAW:0]      odata0; 
wire                    ovalid0;
wire    [`VCHW:0]       ovch0;  
wire    [`PORTW:0]      port0;  
wire                    req0;   
wire                    send0;  
wire    [`DATAW:0]      bdata0; 
wire    [`TYPEW:0]      btype0; 

wire    [`VCH:0]        vcsel;

assign  oack[0]        = send0;

/* 
 * VC mux 
 */ 
vcmux vcmux ( 
        .ovalid0 ( ovalid0 ),

        .odata0  ( odata0 ),

        .ovch0   ( ovch0 ),

        .req0    ( req0 ),

        .port0   ( port0 ),

        .ovalid  ( ovalid ),
        .odata   ( odata  ),
        .ovch    ( ovch   ),
        .req     ( req    ),
        .port    ( port   ),
        .vcsel   ( vcsel  ),

        .clk     ( clk    ),
        .rst_    ( rst_   ) 
);

/* 
 * Input virtual channels 
 */ 
vc #( ROUTERID, PCHID, 0 ) vc_0 ( 
       .bdata ( bdata0  ), 
       .send  ( send0   ), 
       .olck  ( olck[0] ), 

       .irdy_0( irdy_0  ), 
       .irdy_1( irdy_1  ), 
       .irdy_2( irdy_2  ), 
       .irdy_3( irdy_3  ), 
       .irdy_4( irdy_4  ), 
       .ilck_0( ilck_0  ), 
       .ilck_1( ilck_1  ), 
       .ilck_2( ilck_2  ), 
       .ilck_3( ilck_3  ), 
       .ilck_4( ilck_4  ), 

       .grt_0 ( vcsel[0] ? grt_0 : `Disable ), 
       .grt_1 ( vcsel[0] ? grt_1 : `Disable ), 
       .grt_2 ( vcsel[0] ? grt_2 : `Disable ), 
       .grt_3 ( vcsel[0] ? grt_3 : `Disable ), 
       .grt_4 ( vcsel[0] ? grt_4 : `Disable ), 

       .req   ( req0    ),
       .port  ( port0   ),
       .ovch  ( ovch0   ),

       .clk ( clk  ), 
       .rst_( rst_ )  
);                  

/*  
 * Data transmission 
 */ 
 // vc.v를 통해 전송 안됨 혹은 type이 none이라면 data는 0, 아니면 data제대로 out에 전달
assign  odata0   = send0 ? bdata0 : `DATAW_P1'b0; 

assign  ovalid0  = send0; // vaild신호를 odata 선정과 같이 줌

assign  btype0  = bdata0[`TYPE_MSB:`TYPE_LSB];  //type 결정

/* 
 * Routing computation logic - port선정해줌
 */ 
rtcomp rc0 ( 
        .addr   ( bdata0[`DST_MSB:`DST_LSB] ),
        .ivch   ( bdata0[`VCH_MSB:`VCH_LSB] ),
        .en     ( btype0 == `TYPE_HEAD || btype0 == `TYPE_HEADTAIL ), //tyoe이 head라면 en신호 활성화
        .port   ( port0  ),
        .ovch   ( ovch0  ),

        .my_xpos( my_xpos ),
        .my_ypos( my_ypos ),

        .clk    ( clk  ),
        .rst_   ( rst_ ) 
);

/* 
 * Input buffers
 * idata, wr_en이 vc안써서 무조건 동작
 */ 
fifo    ibuf0 ( 
        .idata  ( ivch == 0 ? idata  : `DATAW_P1'b0 ), 
        .odata  ( bdata0 ), 

        .wr_en  ( ivch == 0 ? ivalid : `Disable ), 
        .rd_en  ( send0 ), 
        .empty  ( /* not used */ ), 
        .full   ( /* not used */ ), 
        .ordy   ( ordy[0]        ), 

        .clk    ( clk  ), 
        .rst_   ( rst_ )  
); 
endmodule
