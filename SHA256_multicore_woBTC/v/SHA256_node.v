//module for sha
//wrapper for assembler and sha256_core
//
//24-feb-18, added state machine, changed variable names
//
//29-feb-18 bug fixes
//known issues- vcs error, deassembler
module SHA256_node #(parameter ring_width_p = "inv", parameter id_p="inv")
	(input				clk_i
	,input				reset_i
	,input				en_i
	,input				v_i
	,input				yumi_i
	,input	[ring_width_p-1:0] 	data_i
	,output	logic			ready_o
	,output logic			v_o
	,output [ring_width_p-1:0]	data_o
	);							

	logic	core_ready_o, core_v_i, core_yumi_i, core_v_o, core_en_i
		,assembler_v_i, assembler_v_o,assembler_ready_o, assembler_en_i, assembler_yumi_i, deassembler_en_i, deassembler_v_o, deassembler_ready_o, deassembler_v_i;
	reg	[95:0]	assembler_data_o;
	reg	[255:0] core_data_o;



 reg [2:0] counter,counter_n;

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



	SHA256_multicore	#(.core_size(1))
		multicore	(.clk_i(clk_i)
				,.reset_i(reset_i)
				,.en_i(core_en_i)
				,.v_i(assembler_v_o)
				,.yumi_i(deassembler_ready_o)
				,.data_i(assembler_data_o)
				,.ready_o(core_ready_o)
				,.v_o(core_v_o)
				,.data_o(core_data_o)
				);



	bsg_deassembler		#(.ring_width_p( ring_width_p), .id_p(id_p))
		deassembler	(.clk_i(clk_i)
                                ,.reset_i(reset_i)
                                ,.en_i(deassembler_en_i)
                                ,.v_i(core_v_o)
                                ,.yumi_i(yumi_i)
                                ,.data_i(core_data_o)
                                ,.ready_o(deassembler_ready_o)
                                ,.v_o(deassembler_v_o)
                                ,.data_o(data_o)
                                );
	
	localparam WAIT	= 2'b00;
	localparam CALC	= 2'b01;
	localparam DONE	= 2'b10;

	reg [1:0] state_next;
	reg [1:0] state;

	bsg_dff_en #(.width_p(2))
		state_thingy	(.clock_i(clk_i)
			    	,.data_i(state_next)
	                	,.en_i(1'b1)
				,.data_o(state)
                                );

        always_comb	begin
		case(state)
			WAIT: begin
				assembler_en_i = 1'b1;
				core_en_i = 1'b0;
				deassembler_en_i = 1'b0;
				ready_o = 1'b1;
				v_o = 1'b0;
			end
			CALC: begin
				ready_o = 1'b0;
				v_o = 1'b0;
				if(assembler_v_o==1'b1) 
				begin
					core_en_i = 1'b1;
					assembler_en_i = 1'b0;
					deassembler_en_i = 1'b0;
					if(core_v_o == 1'b1)
					begin
						
						core_en_i = 1'b0;
						deassembler_en_i = 1'b1;
						assembler_en_i = 1'b0;	
					end 
				end
			end
			DONE: begin
				core_en = 1'b0;
				assembler = 1'b0;
				ready_o = 1'b1;
				if(deassembler_v_o)
				begin
				v_o	= 1'b1;
				assembler_en_i = 1'b0;
				core_en_i = 1'b0;
				deassembler_en_i = 1'b1;
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
	        				state_next = CALC;
				end
				CALC: begin
					if(core_v_o == 1'b1)
						state_next = DONE;
				end
   				DONE: begin
					if (yumi_i == 1'b1)
					begin
					counter = counter + 1;			
					end	
					if(counter == 3'b100)	
					begin	
					state_next = WAIT;			
					end
				end
			endcase
		end
	end
endmodule

