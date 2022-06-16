`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2022 07:05:36
// Design Name: 
// Module Name: DigitalAlarmClock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module DigitalAlarmClock(clk,TimeReset,AlarmReset,TimeSettingMode,IncMin,IncHour,IncAlarmMin,EnableAlarm,AlarmLED,IncAlarmHour,DisplayAlarm,Segment,Anode);
input clk,TimeReset,TimeSettingMode,IncMin,IncHour,AlarmReset,IncAlarmMin,IncAlarmHour,EnableAlarm,DisplayAlarm;
wire [3:0]SS,SM,MS,MM,HS,HM,AMS,AMM,AHS,AHM;
output AlarmLED;
output [6:0] Segment;
output [7:0] Anode;
wire pb0,pb1,pb2,pb3,nclk;
clockDivider m0(clk,nclk);
Time m1(nclk,TimeReset,TimeSettingMode,pb2,pb3,SS,SM,MS,MM,HS,HM);
Alarm m2(AlarmReset,pb0,pb1,AMS,AMM,AHS,AHM);
Comparator m3(MS,MM,HS,HM,AMS,AMM,AHS,AHM,EnableAlarm,AlarmLED);
SevenSeg_Driver3 m4(clk,HM,HS,MM,MS,SM,SS,AHM,AHS,AMM,AMS,Segment,Anode,DisplayAlarm,AlarmReset,TimeReset);
pushbutton m5(IncAlarmMin,clk,pb0);
pushbutton m6(IncAlarmHour,clk,pb1);
pushbutton m7(IncMin,clk,pb2);
pushbutton m8(IncHour,clk,pb3);
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module DigitalAlarmClocktb();
reg clk,TimeReset,TimeSettingMode,IncMin,IncHour,AlarmReset,IncAlarmMin,IncAlarmHour,EnableAlarm,DisplayAlarm;
wire AlarmLED;
wire [6:0] Segment;
wire [7:0] Anode;
DigitalAlarmClock z1(clk,TimeReset,AlarmReset,TimeSettingMode,IncMin,IncHour,IncAlarmMin,EnableAlarm,AlarmLED,IncAlarmHour,DisplayAlarm,Segment,Anode);
initial
	 begin
	  clk = 0;
	   forever 
		  #5 clk = ~clk;
		  end
		  initial
		  begin
		  DisplayAlarm = 0;
		  TimeReset = 0;AlarmReset = 0;
		  IncHour = 0;IncMin = 0;
		  EnableAlarm =1; 
		  #5 TimeReset = 1;AlarmReset = 1;
		  #10 TimeReset = 0;AlarmReset = 0;
		  TimeSettingMode = 0;
 #15 IncAlarmMin = 0;IncAlarmHour = 0;
   #20 IncAlarmMin = 1;IncAlarmHour = 1;
	#25 IncAlarmMin = 0;IncAlarmHour = 0;
	#30 IncAlarmMin = 1;IncAlarmHour = 1;
    #35 IncAlarmMin = 0;IncAlarmHour = 0;
		  #50 TimeSettingMode = 0;
		  #60 TimeReset= 0;
		  #70 TimeReset = 1;
		  #80 TimeReset = 0;
		 #500 DisplayAlarm = 1;
		  #505 IncHour = 0;IncMin = 0;
		  #510 IncHour = 1;IncMin = 1;
		  #515 IncHour = 0;IncMin = 0;
		  #520 IncHour = 1;IncMin = 1;
		  #525 IncHour = 0;IncMin = 0;
		  #550 AlarmReset= 0;
		  #560 AlarmReset = 1;
		  #570 AlarmReset = 0;
		  #5000 $stop;
		  end
endmodule
//////////////////////////////////////////Time/////////////////////////////////////////
module Time(clk,TimeReset,SelMode,IncMin,IncHour,SS,SM,MS,MM,HS,HM);
input clk,TimeReset,SelMode,IncMin,IncHour;
output [3:0]SS,SM,MS,MM,HS,HM;
wire w1,w2,w3,w4,w5,w6;
Mod10_Counter k0(clk,TimeReset,SS,w1);
Mod6_Counter k1(w1,TimeReset,SM,w2);
mux_2x1 k2(w2,IncMin,SelMode,w3);
Mod10_Counter2 k3(w3,TimeReset,MS,w4);
Mod6_Counter k4(w4,TimeReset,MM,w5);
mux_2x1 k5(w5,IncHour,SelMode,w6);
Hour_24 k6(w6,TimeReset,HS,HM);
endmodule
///////////////////////////////////////////////////////////////////////////////////////////
module Mod10_Counter(clk,rst,count,q);
input clk,rst;
output reg[3:0]count;
output reg q;
always@(posedge clk or posedge rst)
begin
  if(rst|count==4'b1001)
   begin
   count<=0;
   q <= 0;
   end
	else
	   begin
		count<=count+1;
		if(count==8)begin q <= 1; end
		end
	end
	endmodule
/////////////////////////////////////////////////////////////////////////////////////////////
module Mod6_Counter(clk,rst,count,q2);
input clk,rst;
output reg[3:0]count;
output reg q2;
always@(negedge clk or posedge rst)
begin
  if(rst|count==4'b0101)
   begin
   count<=0;
   q2 <= 0;
   end
	else
	   begin
		count<=count+1;
		if(count==4)begin q2 <= 1; end
		end
	end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////
module Mod10_Counter2(clk,rst,count,q);
input clk,rst;
output reg[3:0]count;
output reg q;
always@(negedge clk or posedge rst)
begin
  if(rst|count==4'b1001)
   begin
   count<=0;
   q <= 0;
   end
	else
	   begin
		count<=count+1;
		if(count==8)begin q <= 1; end
		end
	end
	endmodule
///////////////////////////////////////////////////////////
module mux_2x1(a,b,s,y);
input a,b,s;
output y;
assign y = ((~s)&a )|(s&b);
endmodule
////////////////////////////////////////////////////////////
module clockDivider(clk,nclk);
input clk;
output reg nclk;
reg [31:0]count=32'd0;
always@(posedge clk)
begin
count= count+1;
nclk = count[26];
end
endmodule
///////////////////////////////////////////////////////////////
module Hour_24(clk,rst,sec,Min);
input clk,rst;
output reg [3:0]sec,Min;
always@(negedge clk or posedge rst)
begin
  if(rst) 
  begin
     sec <= 0;
	 Min <= 0;
   end
else if(sec == 4'd3 && Min == 4'd2)
   begin
   sec <= 0;
   Min <= 0;
   end
else 
begin 
    if(sec == 9)
    begin
    Min <= Min+1'd1; 
       sec<= 0;
       end 
	else 
    sec <= sec + 1'd1;  
		 end
end
endmodule
//////////////////////////////////////Alarm Module//////////////////////////////////////////
module Alarm(AlarmReset,IncAlarmMin,IncAlarmHour,AMS,AMM,AHS,AHM);
input AlarmReset,IncAlarmMin,IncAlarmHour;
output [3:0]AMS,AMM,AHS,AHM;
wire w1,w2,w3;
Mod10_Counter l0(IncAlarmMin,AlarmReset,AMS,w1);
Mod6_Counter l1(w1,AlarmReset,AMM,w2);
Hour_24 l2(w3,AlarmReset,AHS,AHM);
or l3(w3,w2,IncAlarmHour);
endmodule
///////////////////////////////////////////Comparator/////////////////////////////////////////////
module Comparator(MS,MM,HS,HM,AMS,AMM,AHS,AHH,Enable,Equal);
input [3:0]MS,MM,HS,HM,AMS,AMM,AHS,AHH;
input Enable;
output reg Equal;
always@(*)
begin
if(Enable) 
begin 
if((MS == AMS) && (MM == AMM) && (HS == AHS) && (HM == AHH)) 
  Equal <= 1;
else
  Equal <= 0;
end
else
  Equal <= 0; 
   end 
endmodule 
//////////////////////////////////////////////////////Alarm 7-Segment Module////////////////////////////////////////
module SevenSeg_Driver3(clk,in1,in2,in3,in4,in5,in6,Ain1,Ain2,Ain3,Ain4,seg,an,Display_Alarm,Alarm_rst,Time_rst);
input clk,Display_Alarm,Alarm_rst,Time_rst;
input [3:0] in1,in2,in3,in4,in5,in6,Ain1,Ain2,Ain3,Ain4;
output [6:0]seg;
output [7:0]an;
wire [6:0]segTemp;
wire [7:0]anTemp;
wire [6:0]segTemp1;
wire [7:0]an1;
SevenSeg_Driver2 k0(clk,in1,in2,in3,in4,in5,in6,segTemp,anTemp,Time_rst);
SevenSeg_Driver k1(clk,Ain1,Ain2,Ain3,Ain4,segTemp1,an1,Alarm_rst);
An k2(anTemp,an1,an,Display_Alarm);
seg k3(segTemp,segTemp1,seg,Display_Alarm);
endmodule
//////////////////////////////////////////////////////////////////////////
module SevenSeg_Driver2(clk,in1,in2,in3,in4,in5,in6,seg,an,rst);
input clk,rst;
input [3:0] in1,in2,in3,in4,in5,in6;
output reg [6:0] seg;
output reg [7:0] an;
wire [6:0] seg1,seg2,seg3,seg4,seg5,seg6;
reg [15:0] nclk;
parameter LEFT1 = 3'b000, LEFT2 = 3'b001, MIDLEFT1 = 3'b010, MIDLEFT2 = 3'b011, RIGHT2 = 3'b100, RIGHT1 = 3'b101;
reg [2:0] state = LEFT1;
always@(posedge clk)
nclk <= nclk + 1'b1;
always@(posedge nclk[15] or posedge rst)
//always@(posedge clk or posedge rst)
begin
  if(rst == 1)
  begin
    seg <= 7'b1000000;
    an <= 8'b11000000;
    state <= LEFT1;
    end
 else
    begin
    case(state)
    LEFT1:
    begin 
    seg <= seg1;
    an <= 8'b11011111;
    state <= LEFT2;
    end
    LEFT2:
    begin 
    seg <= seg2;
     an <= 8'b11101111;
    state <= MIDLEFT1;
    end
    MIDLEFT1:
    begin 
    seg <= seg3;
     an <= 8'b11110111;
    state <= MIDLEFT2;
    end
    MIDLEFT2:
    begin 
    seg <= seg4;
    an <= 8'b11111011;
    state <= RIGHT1;
    end
    RIGHT1:
    begin 
    seg <= seg5;
    an <= 8'b11111101;
    state <= RIGHT2;
    end
    RIGHT2:
    begin 
    seg <= seg6;
    an <= 8'b11111110;
    state <= LEFT1;
    end
    endcase
    end
    end
    Seven_Segment_Display_Decoder t0(in1,seg1);
    Seven_Segment_Display_Decoder t1(in2,seg2);
    Seven_Segment_Display_Decoder t2(in3,seg3);
    Seven_Segment_Display_Decoder t3(in4,seg4);
    Seven_Segment_Display_Decoder t4(in5,seg5);
    Seven_Segment_Display_Decoder t5(in6,seg6);
    endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Seven_Segment_Display_Decoder(bcd,seg);
input [3:0]bcd;
output reg [6:0]seg;
always@(bcd)
begin
case(bcd)
            0 : seg <= 7'b1000000;
            1 : seg <= 7'b1111001;
            2 : seg <= 7'b0100100;
            3 : seg <= 7'b0110000;
            4 : seg <= 7'b0011001;
            5 : seg <= 7'b0010010;
            6 : seg <= 7'b0000010;
            7 : seg <= 7'b1111000;
            8 : seg <= 7'b0000000;
            9 : seg <= 7'b0010000; 
        endcase
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module SevenSeg_Driver(clk,in1,in2,in3,in4,seg,an,rst);
input clk,rst;
input [3:0] in1,in2,in3,in4;
output reg [6:0] seg;
output reg [7:0] an;
wire [6:0] seg1,seg2,seg3,seg4;
reg [15:0] nclk;
parameter LEFT = 2'b00, MIDLEFT = 2'b01, MIDRIGHT = 2'b10, RIGHT = 2'b11;
reg [1:0] state = LEFT;
always@(posedge clk)
nclk <= nclk + 1'b1;
always@(posedge nclk[15] or posedge rst)
//always@(posedge clk or posedge rst)
begin
  if(rst == 1)
  begin
    seg <= 7'b1000000;
    an <= 8'b11110000;
    state <= LEFT;
    end
 else
    begin
    case(state)
    LEFT:
    begin 
    seg <= seg1;
    an <= 8'b11110111;
    state <= MIDLEFT;
    end
    MIDLEFT:
    begin 
    seg <= seg2;
    an <= 8'b11111011;
    state <= MIDRIGHT;
    end
    MIDRIGHT:
    begin 
    seg <= seg3;
    an <= 8'b11111101;
    state <= RIGHT;
    end
    RIGHT:
    begin 
    seg <= seg4;
    an <= 8'b11111110;
    state <= LEFT;
    end
    endcase
    end
    end
    Seven_Segment_Display_Decoder t0(in1,seg1);
    Seven_Segment_Display_Decoder t1(in2,seg2);
    Seven_Segment_Display_Decoder t2(in3,seg3);
    Seven_Segment_Display_Decoder t3(in4,seg4);
    endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////
module An(a,b,y,sel);
input [7:0]a;
input [7:0]b;
input sel;
output reg [7:0]y;
always@(a or b or sel)
begin
if(sel) 
y<=b;
else
y<=a;
end
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////
module seg(a,b,y,sel);
input [6:0]a;
input [6:0]b;
input sel;
output reg [6:0]y;
always@(a or b or sel)
begin
if(sel) 
y<=b;
else
y<=a; 
end
endmodule
////////////////////////////////////////////////////////////////
module DFF(clk,d,q,qbar);
input clk,d;
output reg q,qbar;
always@(posedge clk)
begin
 q<=d;
 qbar<=~d;
 end
 endmodule
////////////////////////////////////////////////////////////////////////////////
module pushbutton(pb,clk,led);
input pb,clk;
output led;
wire Q1,Q2_bar,nclk;
clockDivider r0(clk,nclk);
DFF k0(clk,pb,Q1, );
DFF k1(nclk,Q1, ,Q2_bar);
and k2(led,Q1,Q2_bar);
endmodule
//////////////////////////////////////////////////////////////////////////////////////
