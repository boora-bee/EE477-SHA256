// This is the assembler module that takes four inputs and convert them into
// 	one 256-bit output
//
// Comments on update:
//
// input:
//
//
// output:
//
//
// Last modified on: Tue Mar  6 19:34:18 2018

module bsg_assembler
  	(input  		clk_i
  	,input  		reset_i
  	,input  		en_i
  	,input        		v_i
	,input			yumi_i
  	,input		[63:0] data_i
  	,output	logic        	ready_o
  	,output	logic          	v_o
  	,output	reg	[95:0] data_o
  	);

	

	wire [63:0] first_out;
	wire [31:0] in1_i;
	wire [31:0] in2_i;
	wire [31:0] second_i;
	wire [31:0] second_o;
	assign join_i = data_i;  //first pass
	assign in1_i = data_i [31:0];
	assign in2_i = data_i [63:32];
	assign second_i = data_i [31:0];

	localparam IN1 = 2'b00;
	localparam IN2 = 2'b01;
	localparam DONE = 2'b10;
	reg [1:0] state, state_next;
	
	logic en_1; 
	logic en_2;

	
	wire [63:0] first_i;
	wire [63:0] first_o;
	assign first_i = {in2_i, in1_i};
	bsg_dff_en #(.width_p(64))
		in1	(.clock_i(clk_i)
            		,.data_i(first_i)
            		,.en_i(en_1)
            		,.data_o(first_o)
            		);

	bsg_dff_en #(.width_p(32))
		in2     (.clock_i(clk_i)
            		,.data_i(second_i)
            		,.en_i(en_2)
            		,.data_o(second_o)
            		);


bsg_dff_en #(.width_p(2))
   state_thingy(.clock_i(clk_i)
   ,.data_i(state_next)
    ,.en_i(1'b1)
   ,.data_o(state)
    );



	always_comb 
		
		begin        
		case(state)
			IN1: begin
				ready_o = 1'b1;
				v_o = 1'b0;
				en_1 = 1'b1;
				en_2 = 1'b0;
			end

			IN2: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en_1 = 1'b0;
        			en_2 = 1'b1;		
        		end

			DONE: begin
				ready_o =1'b0;
				v_o = 1'b1;
				en_1 = 1'b0;
        			en_2 = 1'b0;
			assign	data_o = {second_o,first_o};
			end
		endcase
	end
always @(*)
        begin

        if(reset_i==1)
	       
         	state_next = IN1;
		
        else
                begin
                        state_next = state;
                case
                        (state)
			
			
                        IN1:
                                if( v_i == 1'b1 )
                                        state_next = IN2;
                        IN2 :
                                if(v_i == 1'b1)
                                        state_next = DONE;
                        DONE:
                                if(yumi_i & v_i)
                                        state_next = IN1;
endcase
end
end
endmodule




