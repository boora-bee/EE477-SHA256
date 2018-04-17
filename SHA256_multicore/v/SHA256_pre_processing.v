// This is the pre_processing module which padded the 256-bit input message to
// 	get a 512-bit output which will be sent to message scheduler
//
// Comment on update:
// 	The original understanding of pre_processing is mistaken, the correct
// 	way should be simply add 1 bit 1 at the end and padded with zeros
//
// input
// 	msg_i:		256 bit input from fsb
//
// output
//	pre_proc_o:	padded msg to send to message_scheduler
//
// Last modified on :	Tue Feb 27 15:11:23 2018
module SHA256_pre_processing
	(input		[127:0]	msg_i	
	,output		[511:0]	pre_proc_o
	);

reg [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15;

		assign	w0 =  msg_i[31:0];
		assign	w1 =  msg_i[63:32];
		assign	w2 =  msg_i[95:64] ;
		assign	w3 =  msg_i[127:96];                        
		assign	w4 = 32'b0;
		assign	w5 = 32'b0;
		assign	w6 = 32'b0;
		assign	w7 = 32'b0;
		assign	w8 = 32'b0;
		assign	w9 = 32'b0;                                                                        
		assign	w10 = 32'b0;
		assign	w11 = 32'b0;
		assign	w12 = 32'b0;
		assign	w13 = 32'b0;                                                
		assign	w14 = 32'b0;
		assign  w15 = 32'b00000000_00000000_00000000_00011000; 
	assign pre_proc_o = {w15,w14,w13,w12,w11,w10,w9,w8,w7,w6,w5,w4,w3,w2,w1,w0};
endmodule
