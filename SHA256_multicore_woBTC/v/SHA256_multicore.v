// This is the multicore controller for SHA256, currently implementing by
// 	state machine
//
// Comments on update:
//	initial version of multicore controller to replace SHA256_core module
//	implemented using state machine
//	
//	module used: bsg_mem_1r1w  
//
//	Problems encountered:
//		1. For Kt_mem: How can I use modules from bsg_mem to create
//		a multiple read port read-only memory instead of creating
//		a Kt_mem for every core?
//		2. round-robin?
//		3.fifo on input and output?
// 
// input:
//	
//
// output:
//
//
//
// Last modified on:
//
//
module SHA256_multicore #(parameter core_size = "inv")
	(input			clk_i
	,input			reset_i
	,input			en_i
	,input			v_i
	,input			yumi_i
	,input		[95:0]	data_i
	,output	logic		ready_o
	,output logic		v_o
	,output 	[255:0]	data_o
	);							


	// cycle_counter reg
	reg		core_ctr_rst, core_ctr_en;
	reg [5:0]	core_ctr;

	reg [255:0] midstate;
	assign midstate = 256'h56f6950a86a3a5297961969c7bfdb28c54c9af5a951237b87979d96fc01823e1;
	// pre_proc
	reg [511:0] block;

	
	
	SHA256_pre_processing
		pre_proc(.msg_i(data_i)
			,.pre_proc_o(block)
			);


	// sipo control logic
	reg 				sipo_rst, sipo_ready;
	logic [$clog2(core_size+1)-1:0]	sipo_yumi;
	logic [core_size-1:0] 		sipo_vo;
	logic [core_size-1:0][511:0]	sipo_mem;
	
	bsg_serial_in_parallel_out #(.width_p(512), .els_p(core_size), .out_els_p(core_size))
		sipo	(.clk_i(clk_i)
			,.reset_i(reset_i | sipo_rst)
			,.valid_i(v_i)
			,.data_i(block)
			,.ready_o(sipo_ready)
			,.valid_o(sipo_vo)
			,.data_o(sipo_mem)
			,.yumi_cnt_i(sipo_yumi)
			);
			

			
	// Kt_mem
	reg [31:0] Kt_r;
	
	SHA256_Kt_mem
		Kt_mem	(.addr(core_ctr)
			,.Kt_o(Kt_r)
			);	
	
		
	// Core control logic
	reg 		    core_rst, core_en, core_yumi, core_vi; 
	reg [core_size-1:0] core_vo, core_ready;
	logic [core_size-1:0][511:0] core_data_i;
	logic [core_size-1:0][255:0] core_data_o;
	

	// piso control logic
	logic	piso_vi, piso_vo, piso_ready, piso_yumi;
	logic	[255:0]			piso_out;
	logic	[core_size-1:0][255:0]	piso_in;
	

	// connet control logic between sipo and cores
	assign core_vi = & sipo_vo;
	assign sipo_yumi = {$clog2(core_size+1) {&core_ready}};
	assign core_data_i = sipo_mem;
	assign core_yumi = piso_ready;

	
	genvar i;
	generate
		for (i = 0; i < core_size; i++) begin
			SHA256_core #(.core_id(i))
			    core(.clk_i(clk_i)
				,.reset_i(core_rst)
				,.en_i(core_en)
				,.v_i(core_vi)
				,.yumi_i(core_yumi)
				,.msg_i(core_data_i[i][511:0])
				,.Kt_i(Kt_r)
				,.core_ctr_i(core_ctr)
				,.ready_o(core_ready[i])
				,.v_o(core_vo[i])
				,.digest_o(core_data_o[i])
				);
		end
	endgenerate
	
	assign piso_vi = & core_vo;
	assign piso_in = core_data_o;

	
	bsg_parallel_in_serial_out #(.width_p(256), .els_p(core_size))
		piso	(.clk_i(clk_i)
			,.reset_i(reset_i)
			,.valid_i(piso_vi)
			,.data_i(piso_in)
			,.ready_o(piso_ready)
			,.valid_o(piso_vo)
			,.data_o(piso_out)
			,.yumi_i(piso_yumi)
			);

	assign piso_yumi = yumi_i;
	assign data_o = piso_out;
	assign v_o = piso_vo;



	// state reg
	typedef enum [3:0] {eWait, eSIPO, eComp, ePISO, eDone} state_e;
	state_e state_n, state_r;

	always_ff @(posedge clk_i) begin
		if (reset_i) begin
			state_r <= eWait;	
		end else if (en_i) begin
			state_r <= state_n;
		end else begin
			state_r <= state_r;
		end
	end
	
	
	
	always_ff @(posedge clk_i) begin
		if (reset_i | core_ctr_rst) begin
			core_ctr = 6'b0;
		end else if (core_ctr_en) begin
			core_ctr = core_ctr + 1'b1;
		end else begin
			core_ctr = core_ctr;
		end
	end

        always_comb	begin
		case(state_r)
			eWait: begin
				ready_o = 1'b1;
				core_ctr_en = 1'b0;
				core_en = 1'b0;
				if (v_i & sipo_ready) begin
					state_n = eSIPO;
				end
			end

			eSIPO: begin // filling sipo
				core_ctr_en = 1'b0;
				core_en = 1'b0;
				ready_o = 1'b0;
				if (sipo_vo & core_ready) begin
					state_n = eComp;
				end
			end

			eComp: begin //Hashing
				ready_o = 1'b0;
				core_ctr_en = 1'b1;
				core_en = 1'b1;
				if (core_vo & piso_ready) begin
					state_n = ePISO;
					core_ctr_rst = 1'b1;
				end
			end
			
			ePISO: begin // sending out through PISO
				core_ctr_en = 1'b0;
				core_en = 1'b0;
				ready_o = 1'b1;
				if (yumi_i & piso_ready) begin
					state_n = eWait;	
				end
			end
		endcase
	end
endmodule
