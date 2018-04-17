// This is the SHA256_core module which comb/ines pre-processing, message
// message scheduler and compression together
//
// Comment on update:
// 	remove v_r, v_n and assign v_o directly in FSM; changed cycle_counter
// 	update logic
// 	------------------------------------------------------------------------
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
// Last modified on: Thu Mar  1 21:24:16 2018
module SHA256_core #(parameter core_id = "inv")
	(input 				clk_i
	,input 				reset_i
	,input 				en_i
	,input 				v_i
	,input 				yumi_i
	,input		[511:0]		msg_i
	,input		[31:0]		Kt_i
	,input		[5:0]		core_ctr_i
	,output logic			ready_o
	,output logic			v_o
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
	reg	[31:0]		Wt_r;
	
	// state
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	state_e state_n, state_r;	
	
	// data flow
	reg	[255:0]		msg_r, msg_n;
	 
	
	reg msg_sch_init;
	assign  msg_sch_init = (state_n == eBusy);

	SHA256_message_scheduler
		msg_sch	(.M_i(msg_i)
			,.clk_i(clk_i)
			,.reset_i(reset_i)
			,.init_i(msg_sch_init)
			,.core_ctr_i(core_ctr_i)
			,.Wt_o(Wt_r)
			);

	SHA256_compression
		comp	(.message_i({msg_r})
			,.Kt_i(Kt_i)
			,.Wt_i(Wt_r)
			,.digest_o(digest_r)
			);

	always @(posedge clk_i) begin
		if (reset_i) begin
			state_r <= eWait;
			msg_r <= 256'b0;
		end else if (en_i) begin
			state_r <= state_n;
			msg_r <= msg_n;
		end else begin
			state_r <= state_r;
			msg_r <= msg_r;
		end
	end
	
	always_comb begin
		case(state_r)
			eWait: begin
				ready_o = 1'b1;
                                v_o = 1'b0;
				if (v_i) begin
					state_n = eBusy;
					msg_n = msg_init;
				end
			end
			
			eBusy: begin
				v_o = 1'b0;
				ready_o = 1'b0;
				if (core_ctr_i == 6'b111111) begin
					state_n = eDone;
					digest_o = digest_r + msg_init;
				end else begin
					state_n = eBusy;
					msg_n = digest_r;
				end
			end

			eDone: begin
				v_o = 1'b1;
				ready_o = 1'b1;
				if (yumi_i) begin
					state_n = eWait;
                                end
			end
			
			default: begin
				state_n = eWait;
			end
		endcase
	end
endmodule
