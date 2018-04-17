//module for sha
//wrapper for assembler and sha256_core
//
//24-feb-18, added state machine, changed variable names
//
//29-feb-18 bug fixes
//known issues- vcs error, deassembler
module SHA256_node_multi #(parameter ring_width_p = "inv", parameter id_p="inv")
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

	logic assembler_v_i, assembler_v_o,assembler_ready_o, assembler_en_i, assembler_yumi_i;

logic     [351:0] assembler_data_o;
logic [31:0] one_data_o,two_data_o,one_start_i,two_start_i,one_end_i,two_end_i;
logic sha_en_i,one_ready_o,one_v_o,two_ready_o,two_v_o;
logic [31:0] three_data_o, four_data_o, five_data_o, six_data_o, seven_data_o, eight_data_o, nine_data_o, ten_data_o, eleven_data_o, twelve_data_o, thirteen_data_o, fourteen_data_o, fifteen_data_o, sixteen_data_o;

logic three_ready_o, four_ready_o, five_ready_o, six_ready_o, seven_ready_o, eight_ready_o, nine_ready_o, ten_ready_o, eleven_ready_o, twelve_ready_o, thirteen_ready_o, fourteen_ready_o, fifteen_ready_o, sixteen_ready_o;

logic three_v_o, four_v_o, five_v_o, six_v_o, seven_v_o, eight_v_o, nine_v_o, ten_v_o, eleven_v_o, twelve_v_o, thirteen_v_o, fourteen_v_o, fifteen_v_o, sixteen_v_o;

logic [31:0] three_start_i, four_start_i, five_start_i, six_start_i, seven_start_i, eight_start_i, nine_start_i, ten_start_i, eleven_start_i, twelve_start_i, thirteen_start_i, fourteen_start_i, fifteen_start_i, sixteen_start_i;

logic [31:0] three_end_i, four_end_i, five_end_i, six_end_i, seven_end_i, eight_end_i, nine_end_i, ten_end_i, eleven_end_i, twelve_end_i, thirteen_end_i, fourteen_end_i, fifteen_end_i, sixteen_end_i;


 
assign one_start_i = 	  32'b00000000000000000000000000000000;
assign two_start_i = 	  32'b00010000000000000000000000000001;
assign three_start_i =    32'b00100000000000000000000000000001;
assign four_start_i =     32'b00110000000000000000000000000001;
assign five_start_i =     32'b01000000000000000000000000000001;
assign six_start_i =      32'b01010000000000000000000000000001;
assign seven_start_i =    32'b01100000000000000000000000000001;
assign eight_start_i =    32'b01110000000000000000000000000001;
assign nine_start_i =     32'b10000000000000000000000000000001;
assign ten_start_i =      32'b10010000000000000000000000000001;
assign eleven_start_i =   32'b10100000000000000000000000000001;
assign twelve_start_i =   32'b10110000000000000000000000000001;
assign thirteen_start_i = 32'b11000000000000000000000000000001;
assign fourteen_start_i = 32'b11010000000000000000000000000001;
assign fifteen_start_i =  32'b11100000000000000000000000000001;
assign sixteen_start_i =  32'b11110000000000000000000000000001;

		         
assign one_end_i =      32'b00010000000000000000000000000000;
assign two_end_i =      32'b00100000000000000000000000000000;
assign three_end_i= 	32'b00110000000000000000000000000000;
assign four_end_i = 	32'b01000000000000000000000000000000;
assign five_end_i = 	32'b01010000000000000000000000000000;
assign six_end_i =  	32'b01100000000000000000000000000000;
assign seven_end_i =	32'b01110000000000000000000000000000;
assign eight_end_i =	32'b10000000000000000000000000000000;
assign nine_end_i = 	32'b10010000000000000000000000000000;
assign ten_end_i =  	32'b10100000000000000000000000000000;
assign eleven_end_i =   32'b10110000000000000000000000000000;
assign twelve_end_i =   32'b11000000000000000000000000000000;
assign thirteen_end_i = 32'b11010000000000000000000000000000;
assign fourteen_end_i = 32'b11100000000000000000000000000000;
assign fifteen_end_i =  32'b11110000000000000000000000000000;
assign sixteen_end_i =  32'b11111111111111111111111111111111;





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
				,.yumi_i(one_ready_o)  
				);



	SHA256_node_wrapper
	one	    (.clk_i(clk_i)
   		     ,.reset_i(reset_i)
   		     ,.en_i(sha_en_i)
        	     ,.v_i(assembler_v_o)
        	     ,.nonce_start_i(one_start_i)
       	             ,.nonce_end_i(one_end_i)
        	     ,.yumi_i(yumi_i)
        	     ,.data_i(assembler_data_o)
       		     ,.ready_o(one_ready_o)
       		     ,.v_o(one_v_o)
        	     ,.data_o(one_data_o)
       		     );
	
	SHA256_node_wrapper
	two	     (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(two_start_i)
                     ,.nonce_end_i(two_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(two_ready_o)
                     ,.v_o(two_v_o)
                     ,.data_o(two_data_o)
                     );  

  SHA256_node_wrapper
        three        (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(three_start_i)
                     ,.nonce_end_i(three_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(three_ready_o)
                     ,.v_o(three_v_o)
                     ,.data_o(three_data_o)
                     );
  SHA256_node_wrapper
        four          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(four_start_i)
                     ,.nonce_end_i(four_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(four_ready_o)
                     ,.v_o(four_v_o)
                     ,.data_o(four_data_o)
                     );
  SHA256_node_wrapper
        five          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(five_start_i)
                     ,.nonce_end_i(five_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(five_ready_o)
                     ,.v_o(five_v_o)
                     ,.data_o(five_data_o)
                     );
  SHA256_node_wrapper
        six          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(six_start_i)
                     ,.nonce_end_i(six_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(six_ready_o)
                     ,.v_o(six_v_o)
                     ,.data_o(six_data_o)
                     );
  SHA256_node_wrapper
        seven          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(seven_start_i)
                     ,.nonce_end_i(seven_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(seven_ready_o)
                     ,.v_o(seven_v_o)
                     ,.data_o(seven_data_o)
                     );
  SHA256_node_wrapper
        eight          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(eight_start_i)
                     ,.nonce_end_i(eight_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(eight_ready_o)
                     ,.v_o(eight_v_o)
                     ,.data_o(eight_data_o)
                     );
  SHA256_node_wrapper
        nine          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(nine_start_i)
                     ,.nonce_end_i(nine_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(nine_ready_o)
                     ,.v_o(nine_v_o)
                     ,.data_o(nine_data_o)
                     );

	
  SHA256_node_wrapper
        ten          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(ten_start_i)
                     ,.nonce_end_i(ten_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(ten_ready_o)
                     ,.v_o(ten_v_o)
                     ,.data_o(ten_data_o)
                     );
  SHA256_node_wrapper
eleventeen          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(eleven_start_i)
                     ,.nonce_end_i(eleven_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(eleven_ready_o)
                     ,.v_o(eleven_v_o)
                     ,.data_o(eleven_data_o)
                     );
  SHA256_node_wrapper
        twelve          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(twelve_start_i)
                     ,.nonce_end_i(twelve_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(twelve_ready_o)
                     ,.v_o(twelve_v_o)
                     ,.data_o(twelve_data_o)
                     );
  SHA256_node_wrapper
        thirteen      (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(thirteen_start_i)
                     ,.nonce_end_i(thirteen_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(thirteen_ready_o)
                     ,.v_o(thirteen_v_o)
                     ,.data_o(thirteen_data_o)
                     );
  SHA256_node_wrapper
        fourteen     (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(fourteen_start_i)
                     ,.nonce_end_i(fourteen_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(fourteen_ready_o)
                     ,.v_o(fourteen_v_o)
                     ,.data_o(fourteen_data_o)
                     );
  SHA256_node_wrapper
        fifteen          (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(fifteen_start_i)
                     ,.nonce_end_i(fifteen_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(fifteen_ready_o)
                     ,.v_o(fifteen_v_o)
                     ,.data_o(fifteen_data_o)
                     );
  SHA256_node_wrapper
        sixteen      (.clk_i(clk_i)
                     ,.reset_i(reset_i)
                     ,.en_i(sha_en_i)
                     ,.v_i(assembler_v_o)
                     ,.nonce_start_i(sixteen_start_i)
                     ,.nonce_end_i(sixteen_end_i)
                     ,.yumi_i(yumi_i)
                     ,.data_i(assembler_data_o)
                     ,.ready_o(sixteen_ready_o)
                     ,.v_o(sixteen_v_o)
                     ,.data_o(sixteen_data_o)
                     );
		
	localparam WAIT	= 2'b00;
	localparam CALC = 2'b01;
	localparam DONE	= 2'b10;

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
				ready_o = 1'b1;
				v_o = 1'b0;	
				sha_en_i = 1'b0;
			end
			CALC: begin
				ready_o = 1'b0;
				v_o = 1'b0;
				assembler_en_i = 1'b0;
				sha_en_i = 1'b1;
				end							
			DONE: begin
				ready_o = 1'b0;
                                v_o     = 1'b1;
				if(one_v_o==1'b1)
				begin
				data_o = one_data_o;
				end
				else if(two_v_o == 1'b1)
				begin
				data_o = two_data_o;
				end
				 else if(three_v_o == 1'b1)
                                begin
                                data_o = three_data_o;
                                end
				 else if(four_v_o == 1'b1)
                                begin
                                data_o = four_data_o;
                                end
 				else if(five_v_o == 1'b1)
                                begin
                                data_o = five_data_o;
                                end
 				else if(six_v_o == 1'b1)
                                begin
                                data_o = six_data_o;
                                end
				else if(seven_v_o == 1'b1)
                                begin
                                data_o = seven_data_o;
                                end
				else if(eight_v_o == 1'b1)
                                begin
                                data_o = eight_data_o;
                                end
				else if(nine_v_o == 1'b1)
                                begin
                                data_o = nine_data_o;
                                end
				else if(ten_v_o == 1'b1)
                                begin
                                data_o = ten_data_o;
                                end
				else if(eleven_v_o == 1'b1)
                                begin
                                data_o = eleven_data_o;
                                end
				else if(twelve_v_o == 1'b1)
                                begin
                                data_o = twelve_data_o;
                                end
 				else if(thirteen_v_o == 1'b1)
                                begin
                                data_o = thirteen_data_o;
                                end
				else if(fourteen_v_o == 1'b1)
                                begin
                                data_o = fourteen_data_o;
                                end
 				else if(fifteen_v_o == 1'b1)
                                begin
                                data_o = fifteen_data_o;
                                end
 				else if(sixteen_v_o == 1'b1)
                                begin
                                data_o = sixteen_data_o;
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
					        if(one_v_o == 1'b1 | two_v_o == 1'b1 |three_v_o == 1'b1 |four_v_o == 1'b1| five_v_o == 1'b1| six_v_o == 1'b1| seven_v_o == 1'b1| eight_v_o == 1'b1 |nine_v_o == 1'b1| ten_v_o == 1'b1| eleven_v_o == 1'b1| twelve_v_o == 1'b1| thirteen_v_o == 1'b1| fourteen_v_o == 1'b1| fifteen_v_o == 1'b1| sixteen_v_o == 1'b1)
                                                state_next = DONE;
					else if(v_i ==1'b1)
					state_next = WAIT;
                                end

					DONE: begin
					if(yumi_i == 1'b1 & v_i == 1'b1)
					state_next = WAIT;
				end
			endcase
		end
	end
endmodule

