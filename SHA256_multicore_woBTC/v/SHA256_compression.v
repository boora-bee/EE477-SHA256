// This is the module for the hashing function of the SHA-256 accelerator.
// There are 4 sub-modules inside which are ch, maj, sigma0, sigma1.
//
// input:
// 	clk_i: 		The clock for this module
// 	reset_i:	The reset signal from FSB
// 	message_i:	The input data that needs to be hashed
// 	v_i:		Indicate that the input is valid
// 	yumi_i:		Indicate that the outside world is ready for the output
//	Kt_i: 		The initial Kt value for SHA-256
//	Wt_i:		The Wt value given by message scheduler
//
// output:
// 	ready_o:	Indicate that the module is ready to receive new data
// 	v_o:		Indicate that the module has produced a valid output
// 	digest_o: 	The result of hashing the message
module SHA256_compression
	//input	wire		clk_i
	//,input  wire 		reset_i
	(input  	[255:0] message_i
	//,input       		v_i 		
	//,input 	    		yumi_i
	,input 		[31:0]	Kt_i
	,input		[31:0]  Wt_i
	
	//,output 		ready_o 		 
	//,output wire 		v_o 		
	,output      	[255:0]	digest_o 	
	);

// Assign the input message bits to words A-H
	reg [31:0] A,B,C,D,E,F,G,H;
	assign A = message_i[31:0];
	assign B = message_i[63:32];
	assign C = message_i[95:64];
	assign D = message_i[127:96];
	assign E = message_i[159:128];
	assign F = message_i[191:160];
	assign G = message_i[223:192];
	assign H = message_i[255:224];

// Temp registers for addition
	reg [31:0] sum_wt_kt, sum_wt_kt_ch_H, sum_wt_kt_ch_H_s1, sum_wt_kt_ch_H_s1_D,
		   sum_wt_kt_ch_H_s1_maj, sum_wt_kt_ch_H_s1_maj_s0;

// Temp registers for functions	
	reg [31:0] ch_o, sigma_0_o, maj_o, sigma_1_o;


	ch choose     (.E_i(E), .F_i(F), .G_i(G), .ch_o(ch_o));
	maj majority  (.A_i(A), .B_i(B), .C_i(C), .maj_o(maj_o));
	sigma_0 sigma0(.A_i(A), .sigma_0_o(sigma_0_o));
	sigma_1 sigma1(.E_i(E), .sigma_1_o(sigma_1_o));
	
	assign sum_wt_kt = Wt_i + Kt_i;
	assign sum_wt_kt_ch_H = sum_wt_kt + H + ch_o;
	assign sum_wt_kt_ch_H_s1 = sum_wt_kt_ch_H + sigma_1_o;
	assign sum_wt_kt_ch_H_s1_D = sum_wt_kt_ch_H_s1 + D;
	assign sum_wt_kt_ch_H_s1_maj = sum_wt_kt_ch_H_s1 + maj_o;
	assign sum_wt_kt_ch_H_s1_maj_s0 = sum_wt_kt_ch_H_s1_maj + sigma_0_o;

	assign digest_o = {G, F, E, sum_wt_kt_ch_H_s1_D, C, B, A, sum_wt_kt_ch_H_s1_maj_s0};
endmodule

// The choose function which choose the output based on E.
// For every bit, if E is 1, then the output bit is F; if E is 0, then the
// output b:5
// it is G.
//
// input:
// 	E_i:	word E
// 	F_i:	word F
// 	G_i:	word G
//
// output:
// 	ch_o:	the output of choose function
module ch
	(input 	reg [31:0] E_i
	,input 	reg [31:0] F_i
	,input 	reg [31:0] G_i
	
	,output reg [31:0] ch_o
	);
	
	assign ch_o = (E_i & F_i) ^ (~E_i & G_i);
endmodule

// The majority function tha looks at A,B,C. If the majority of bits at one
// location is 0, the result result of the same location is 0; if the majority
// of bits at one location is 1, the result would be 1.
// input:
// 	A_i: 	word A
// 	B_i: 	word B
//	C_i: 	word C
//
// output:
// 	maj_o: the output of maj function
module maj
	(input 	reg [31:0] A_i
	,input 	reg [31:0] B_i
	,input 	reg [31:0] C_i
	
	,output reg [31:0] maj_o
	);
	
	assign maj_o = (A_i & B_i) ^ (A_i & C_i) ^ (B_i & C_i);
endmodule

// The sigma 0 function rotates bits of A theb sums them together and modulo
// by 2.
// input:
// 	A_i: 	 word A
//
// output:
// 	sigma_0_o:the output of the sigma0 function
module sigma_0
	(input 	reg [31:0] A_i
	
	,output reg [31:0] sigma_0_o
	);
	
	reg [31:0] A_2, A_13, A_22;
	assign A_2 	= {A_i[1:0],  A_i[31:2]};
	assign A_13 	= {A_i[12:0], A_i[31:13]};
	assign A_22 	= {A_i[21:0], A_i[31:22]};
	assign sigma_0_o = (A_2) ^ (A_13) ^ (A_22);
endmodule

// The sigma 1 function rotates bits of E theb sums them together and modulo
// by 2.
// input:
//      E_i:     word E
//
// output:
//      sigma0_o:the output of the sigma0 function
module sigma_1
	(input	reg [31:0] E_i
	
	,output	reg [31:0] sigma_1_o
	);
	
	reg [31:0] E_6, E_11, E_25;
	assign E_6  = {E_i[5:0],  E_i[31:6]};
	assign E_11 = {E_i[10:0], E_i[31:11]};
	assign E_25 = {E_i[24:0], E_i[31:25]}; 
	assign sigma_1_o = (E_6) ^ (E_11) ^ (E_25);
endmodule

