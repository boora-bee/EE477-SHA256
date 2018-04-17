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
  	,output	reg	[351:0] data_o
  	);

	
	wire [63:0] mid1_i;
	wire [63:0] mid2_i;
	wire [63:0] mid3_i;
	wire [63:0] mid4_i;
	wire [63:0] mid1_o;
	wire [63:0] mid2_o;
	wire [63:0] mid3_o;
	wire [63:0] mid4_o;

	assign mid1_i = data_i [63:0];
	assign mid2_i = data_i [63:0];
 	assign mid3_i = data_i [63:0];
 	assign mid4_i = data_i [63:0];

	wire [63:0] first_i;
	wire [31:0] second_i;
	wire [31:0] second_o;
	
	assign second_i = data_i [31:0];
	assign first_i = data_i [63:0];
	localparam IN1 = 3'b000;
	localparam IN2 = 3'b001;
	localparam MID1 = 3'b010;
	localparam MID2 = 3'b011;
	localparam MID3 = 3'b100;
	localparam MID4 = 3'b101;
	localparam DONE = 3'b110;
	reg [2:0] state, state_next;
	
	logic en_1; 
	logic en_2;
	logic en_3;
	logic en_4;
   	logic en_5;
   	logic en_6;


	
	wire [63:0] first_o;
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


		
        bsg_dff_en #(.width_p(64))
                in3     (.clock_i(clk_i)
                        ,.data_i(mid1_i)
                        ,.en_i(en_3)
                        ,.data_o(mid1_o)
                        );


        bsg_dff_en #(.width_p(64))
                in4     (.clock_i(clk_i)
                        ,.data_i(mid2_i)
                        ,.en_i(en_4)
                        ,.data_o(mid2_o)
                        );

  
  
          bsg_dff_en #(.width_p(64))
                  in5     (.clock_i(clk_i)
                          ,.data_i(mid3_i)
                          ,.en_i(en_5)
                          ,.data_o(mid3_o)
                          );

     

        bsg_dff_en #(.width_p(64))
                in6     (.clock_i(clk_i)
                        ,.data_i(mid4_i)
                        ,.en_i(en_6)
                        ,.data_o(mid4_o)
                        );



bsg_dff_en #(.width_p(3))
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
				en_3 = 1'b0;
				en_4 = 1'b0; 
				en_5 = 1'b0;  
				en_6 = 1'b0;
			end

			IN2: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en_1 = 1'b0;
        			en_2 = 1'b1;
                                en_3 = 1'b0;     
                                en_4 = 1'b0;     
                                en_5 = 1'b0;         
                                en_6 = 1'b0;
		
        		end	
			MID1: begin
				
				ready_o = 1'b1;
                                v_o = 1'b0;
                                en_1 = 1'b0;
                                en_2 = 1'b0;
                                en_3 = 1'b1;
                                en_4 = 1'b0;
                                en_5 = 1'b0;
                                en_6 = 1'b0;


			end
			MID2: begin
      				ready_o = 1'b1;
                                v_o = 1'b0;
                                en_1 = 1'b0;
                                en_2 = 1'b0;
                                en_3 = 1'b0;
                                en_4 = 1'b1;
                                en_5 = 1'b0;
                                en_6 = 1'b0;

			end
			MID3: begin
      				ready_o = 1'b1;
                                v_o = 1'b0;
                                en_1 = 1'b0;
                                en_2 = 1'b0;
                                en_3 = 1'b0;
                                en_4 = 1'b0;
                                en_5 = 1'b1;
                                en_6 = 1'b0;
			
			end
			MID4: begin			
      				ready_o = 1'b1;
                                v_o = 1'b0;
                                en_1 = 1'b0;
                                en_2 = 1'b0;
                                en_3 = 1'b0;
                                en_4 = 1'b0;
                                en_5 = 1'b0;
                                en_6 = 1'b1;
			end

			DONE: begin
				ready_o =1'b0;
				v_o = 1'b1;
				en_1 = 1'b0;
        			en_2 = 1'b0;
			assign	data_o = {mid4_o, mid3_o, mid2_o, mid1_o, second_o, first_o};
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
                                        state_next = MID1;
			MID1: if(v_i == 1'b1)
					state_next = MID2;
			MID2: if(v_i == 1'b1)
                                        state_next = MID3;
 			MID3: if(v_i == 1'b1)
                                        state_next = MID4;
			MID4: if(v_i == 1'b1)
                                        state_next = DONE;
                        DONE:
                                if(yumi_i & v_i)
                                        state_next = IN1;
endcase
end
end
endmodule




