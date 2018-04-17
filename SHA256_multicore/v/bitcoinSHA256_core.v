// This is the SHA256_core module which comb/ines pre-processing, message
// message scheduler and compression together
//
// Comment on update:
// 	create a dff for cycle_counter to deal with ICSD error
//	add 2 new control signal ctr_reset (cycle_conter_reset) and ctr_en
//	(cycle_counter_enable)
// input:
// 	clk_i:		the clock that this module runs on
// 	reset_i:	the reset from fsb
// 	en_i:		the enable line from fsb
// 	v_i:		the signal that tells the input data is valid
// 	yumi_i:		the signal that indicate the outside world is ready to
// 			accept our output data
//  	msg_i:		the input message from bsg_assembler
//
// output:
// 	ready_o: 	indicates that our output put
// 	v_o:		indicates that this module has produced valid outputfe
// 	digest_o:	the result of hashing
//
// Last modified on: Tue Feb 27 15:54:07 2018
//
//
//
module bitcoinSHA256_core #(parameter core_id = "inv")
	(input 				clk_i
	,input 				reset_i
	,input 				en_i
	,input 				v_i
	,input 				yumi_i
	,input		[95:0]		msg_i
	,input		[31:0]		nonce
	,output 	logic		ready_o
	,output 	logic		v_o
	,output reg	[255:0]		digest_o
	);

	parameter SHA256_H0 = 32'h6a09e667;
	parameter SHA256_H1 = 32'hbb67ae85;
	parameter SHA256_H2 = 32'h3c6ef372;
	parameter SHA256_H3 = 32'ha54ff53a;
	parameter SHA256_H4 = 32'h510e527f;
	parameter SHA256_H5 = 32'h9b05688c;
	parameter SHA256_H6 = 32'h1f83d9ab;
	parameter SHA256_H7 = 32'h5be0cd19;
	
	parameter msg_init = {SHA256_H7, SHA256_H6, SHA256_H5, SHA256_H4
			     ,SHA256_H3, SHA256_H2, SHA256_H1, SHA256_H0
			     };


	reg 	[255:0]    	digest_r;
	reg	[31:0]		Kt_r;
	reg	[31:0]		Wt_r;
	logic ctr_en;
	
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	state_e state_n, state_r;	
	
	reg [127:0]	padder_i;
	assign padder_i = {msg_i , nonce};

	reg	[255:0]		msg_r, msg_n;
	reg	[511:0]		block;
	reg 		 ctr_reset;
	reg	[6:0]	cycle_counter;
	
	reg msg_sch_init;
	assign  msg_sch_init = (state_n == eBusy);

	reg     [255:0]         midstate;
        assign midstate = 256'h56f6950a86a3a5297961969c7bfdb28c54c9af5a951237b87979d96fc01823e1;

	wire [95:0] send_i;
//	assign block1 = {msg_i,midstate};
//	reg   [511:0] block1;
	

	SHA256_pre_processing
		pre_proc(.msg_i(padder_i)
			,.pre_proc_o(block)
			);

	SHA256_Kt_mem
		Kt_mem	(.addr(cycle_counter[5:0])
			,.Kt_o(Kt_r)
			);		

	SHA256_message_scheduler
		msg_sch	(.M_i(block)
			,.clk_i(clk_i)
			,.reset_i(reset_i)
			,.init_i(msg_sch_init)
			,.Wt_o(Wt_r)
			);

	SHA256_compression
		comp	(.message_i({msg_r})
		,.Kt_i(Kt_r)
			,.Wt_i(Wt_r)
			,.digest_o(digest_r)
			);
//	logic done;
//	SHA256_message_scheduler2
//	   msg2 (.padded(block)
//	    ,.clk(clk_i)
//	    ,.rst(reset_i)
//	    ,.hashed(digest_r)
///	    ,.done(done)
//	    );
//

	always @(posedge clk_i) begin
		if (reset_i) begin
			state_r <= eWait;
			msg_r <= 256'b0;
		end else begin
			state_r <= state_n;
			msg_r <= msg_n;
		end
	end
	
    	always_ff @(posedge clk_i) begin
        	if (reset_i | ctr_reset) begin
             		cycle_counter = 7'b0;
        	end else if (ctr_en) begin
            		cycle_counter = cycle_counter + 1'b1;
	    	end
	end


	always_comb begin
		case(state_r)
			eWait: begin	
				ready_o = 1'b1;
                        	v_o = 1'b0;
				if (v_i==1'b1) begin
					state_n = eBusy;
					msg_n = msg_init;
					ctr_reset = 1'b1;
				end
			end
			
			eBusy: begin
				ctr_en = 1'b1;
                                ctr_reset=1'b0;
				if (cycle_counter == 7'b0111111) begin
					state_n = eDone;
					digest_o = digest_r + msg_init;
				
				//	digest_o = digest_r;
					ready_o = 1'b0;
                                        v_o = 1'b0;
				end else begin
					state_n = eBusy;
					msg_n = digest_r;
					ready_o = 1'b0;
                                        v_o = 1'b0;
					

				end
			end

			eDone: begin
				   ready_o = 1'b0;
                                        v_o = 1'b1;

				if (yumi_i) begin
					state_n = eWait;
					ctr_en = 1'b0;
					ctr_reset = 1'b1;
				//	ready_o = 1'b0;
                                 //       v_o = 1'b1;
				end
			end

			default: begin
				state_n = eWait;
			end
		endcase
	end
endmodule

