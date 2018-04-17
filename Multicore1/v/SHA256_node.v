//module for sha
//wrapper for assembler and sha256_core
//
//24-feb-18, added state machine, changed variable names
//
//29-feb-18 bug fixes
//known issues- vcs error, deassembler
module SHA256_node #(parameter ring_width_p = "inv", parameter id_p="inv")
	(input				clk_i
	,input  logic		 	reset_i
	,input				en_i
	,input				v_i
	,input				yumi_i
	,input	[ring_width_p-1:0] 	data_i
	,output	logic			ready_o
	,output logic			v_o
	,output logic [ring_width_p-1:0]	data_o
	);							

	logic	core_ready_o, core_v_i, core_yumi_i, core1_v_o, core_en_i
		,assembler_v_i, assembler_v_o,assembler_ready_o, assembler_en_i, assembler_yumi_i, deassembler_en_i, deassembler_v_o, deassembler_ready_o, deassembler_v_i, order_i,core1_en_i,core2_en_i,target_en_i,counter_en_i;
	reg	[255:0]	core_data_o,deassembler_data_o,core2_data_o;
	reg     [95:0] assembler_data_o;
	reg 	[31:0] target;
	reg     [31:0] nonce;
//assign	nonce = 32'b00000000000000000000000000000000;
	reg [2:0] counter,counter_n;
	assign target = assembler_data_o [31:0];
logic [31:0] counter_limit;
assign counter_limit = 32'b11111111111111111111111111111111;
logic overflow;
bsg_counter_en_overflow #(.width_p(32))
nonce_counter	(.clk_i(clk_i)
                 ,.reset_i(reset_i)
		 ,.en_i(counter_en_i)
		 ,.limit_i(counter_limit)
		 ,.counter_o(nonce)
		 ,.overflowed_o(overflow)
		);

logic flash;
//wire counter_en_i;

	bsg_assembler #(.ring_width_p( ring_width_p), .id_p(id_p))
		assembler	(.clk_i(clk_i)
				,.reset_i(reset_i)
				,.en_i(assembler_en_i)
				,.v_i(v_i)
				,.data_i(data_i[63:0])
				,.ready_o(assembler_ready_o)
				,.v_o(assembler_v_o)
				,.data_o(assembler_data_o)
				,.yumi_i(core_ready_o)
				);



	bitcoinSHA256_core	
		first_sha	(.clk_i(clk_i)
				,.reset_i(reset_i)
				,.en_i(core1_en_i)
				,.v_i(assembler_v_o)
				,.yumi_i(core2_ready_o)
				,.msg_i(assembler_data_o)
				,.nonce(nonce)
				,.ready_o(core_ready_o)
				,.v_o(core1_v_o)
				,.digest_o(core_data_o)
				);


	 bitcoinSHA256_core2
                double_sha      (.clk_i(clk_i)
                                ,.reset_i(reset_i)
                                ,.en_i(core2_en_i)
                                ,.v_i(core1_v_o)
                                ,.yumi_i(target_ready_o)
                                ,.msg_i(core_data_o)
                                ,.ready_o(core2_ready_o)
                                ,.v_o(core2_v_o)
                                ,.digest_o(core2_data_o)
                                );
		
	bsg_target_check
		walmart		(.clk_i(clk_i)
				,.reset_i(reset_i)
				,.en_i(target_en_i)
				,.v_i(core2_v_o)
				,.yumi_i(yumi_i)
				,.target_i(target)
				,.data_i(core2_data_o)
				,.ready_o(target_ready_o)
                                ,.v_o(target_v_o)
				,.data_o(check)
				);

		

//assign data_o = check;

	
	
	localparam WAIT	= 3'b000;
	localparam CALC1 = 3'b001;
	localparam CALC2 = 3'b010;
	localparam CALC3 = 3'b011;
	localparam DONE	= 3'b100;

	reg [2:0] state_next;
	reg [2:0] state;
	reg [32:0] nonce_next;
	bsg_dff_en #(.width_p(3))
		state_thingy	(.clock_i(clk_i)
			    	,.data_i(state_next)
	                	,.en_i(1'b1)
				,.data_o(state)
                                );
        


        always_comb	begin
		case(state)
			WAIT: begin
				assembler_en_i = 1'b1;
				core1_en_i = 1'b0;
				deassembler_en_i = 1'b0;
				ready_o = 1'b1;
				v_o = 1'b0;	
		      	        core2_en_i = 1'b0;
				target_en_i = 1'b0;
				counter_en_i = 1'b0;
			end
			CALC1: begin
				flash = 1'b0;
				ready_o = 1'b0;
				v_o = 1'b0;
				core1_en_i = 1'b1;
				core2_en_i = 1'b0;
				assembler_en_i = 1'b0;
				target_en_i = 1'b0;
				counter_en_i = 1'b0;
				end
			CALC2: begin
				ready_o = 1'b0;
                                v_o = 1'b0;
				core1_en_i = 1'b0;
				assembler_en_i = 1'b0;	
				core2_en_i = 1'b1;
				target_en_i = 1'b0;
				counter_en_i = 1'b0;
				end
			CALC3: begin
				ready_o = 1'b0;
                                v_o = 1'b0;
				core1_en_i = 1'b0;                      
                                assembler_en_i = 1'b0;
                                core2_en_i = 1'b0;
                                target_en_i = 1'b1;
				counter_en_i = 1'b0;
				end							
			DONE: begin
				if(check == 1'b0)
				begin
				ready_o = 1'b0;
				v_o	= 1'b0;
				assembler_en_i = 1'b0;
				core1_en_i = 1'b0;
				counter_en_i = 1'b1;
				target_en_i = 1'b0;
				core2_en_i = 1'b0;
				flash = 1'b1;
				end
				else if(check == 1'b1 | overflow == 1'b1)
				begin	
				ready_o = 1'b0;
                                v_o     = 1'b1;
				 counter_en_i = 1'b0;
				data_o = nonce;
				end
				end
		endcase
	end

	always @(*) begin
		if(reset_i == 1)
			state_next = WAIT;
		else begin 
			state_next = state;
			case(state)
				WAIT: begin
					if(assembler_v_o == 1'b1)
	        				state_next = CALC1;
				end
				
				CALC1: begin
					        if(core1_v_o == 1'b1)
                                                state_next = CALC2;
                                end

				
				CALC2: begin
					if(core2_v_o == 1'b1)
						state_next = CALC3;
				end
				CALC3: begin
					        if(target_v_o == 1'b1 | overflow == 1'b1)
                                                state_next = DONE;
                                end

   				DONE: begin
					if (check == 1'b1)
					begin
					state_next = WAIT;
					end
					else
					begin
					state_next = CALC1;
					end
				end
			endcase
		end
	end
endmodule

