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
	(input		[95:0]	msg_i
	
	,output		[511:0]	pre_proc_o
	);
	
	assign pre_proc_o = {msg_i, 1'b1, 415'b0};
endmodule
