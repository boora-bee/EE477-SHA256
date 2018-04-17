//takes in digest 256 bits and gives out 64 bit output in 4 trace returns.
//
//
//

module bsg_deassembler #(parameter ring_width_p="inv"           ,parameter id_p="inv")
  (input  clk_i
  ,input  reset_i
  ,input  en_i

  ,input                     v_i

  ,input  reg [255 :0] data_i
  ,output            logic        ready_o

  ,output logic                 v_o
  ,output [ring_width_p -1 :0]         data_o




  ,input                     yumi_i
  );


logic [63:0] in1_out;
logic [63:0] in2_out;
logic [63:0] in3_out;
logic [63:0] in4_out;
logic [63:0] data_o_mid;


assign in1_out = data_i [63:0];
assign in2_out = data_i [127:64];
assign in3_out = data_i [191:128];
assign in4_out = data_i [255:192];

logic en1_i;
logic en2_i;
logic en3_i;
logic en4_i;
localparam CATCH = 3'b000;
localparam OUT1 = 3'b001;
localparam OUT2 = 3'b010;
localparam OUT3 = 3'b011;
localparam OUT4 = 3'b100;

reg [2:0] state,state_next;

//assign data_o = {{(11){1'b0}}, data_o_mid};

//assign data_o = {{(11){1'b0}}, data_o_mid};
 
bsg_dff_en #(.width_p(64))
in1         (.clock_i(clk_i)
            ,.data_i(in1_out)
            ,.en_i(en1_i)
            ,.data_o(data_o)
            );


bsg_dff_en #(.width_p(64))
in2         (.clock_i(clk_i)
            ,.data_i(in2_out)
            ,.en_i(en2_i)
            ,.data_o(data_o)
            );

bsg_dff_en #(.width_p(64))
in3         (.clock_i(clk_i)
            ,.data_i(in3_out)
            ,.en_i(en3_i)
            ,.data_o(data_o)
            );

bsg_dff_en #(.width_p(64))
in4         (.clock_i(clk_i)
            ,.data_i(in4_out)
            ,.en_i(en4_i)
            ,.data_o(data_o)
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

CATCH	:

        begin
        ready_o = 1'b1;
        v_o = 1'b0;
        end

OUT1:

        begin
        ready_o = 1'b0;
        v_o = 1'b1;
        en1_i = 1'b1;
        en2_i = 1'b0;
        en3_i = 1'b0;
        en4_i = 1'b0;
//data_o = {{(11){1'b0}}, da\_out};
	
//data_o = in1_out; 
        end

OUT2:

        begin
        ready_o = 1'b0;
        v_o = 1'b1;
        en1_i = 1'b0;
        en2_i = 1'b1;
        en3_i = 1'b0;
        en4_i = 1'b0;

        end


OUT3:

        begin
        ready_o = 1'b0;
        v_o =    1'b1;
	en1_i = 1'b0;
        en2_i = 1'b0;
        en3_i = 1'b1;
        en4_i = 1'b0;
     
   end

OUT4:
        begin
        v_o = 1'b0;
        ready_o =1'b1;
	en1_i = 1'b0;
        en2_i = 1'b0;
        en3_i = 1'b0;
        en4_i = 1'b1;

  end
endcase
end


always @(*)
        begin

        if(reset_i==1)
                state_next = CATCH;

        else
                begin
                        state_next = state;
                case
                        (state)
                       CATCH:
				if(v_i == 1'b1)
				 state_next = OUT1;

			 OUT1:
                                if( yumi_i == 1'b1 )
                                        state_next = OUT2;
                        OUT2 :
                               if(yumi_i == 1'b1)
                                        state_next = OUT3;
                        OUT3 :
                                if(yumi_i == 1'b1)
                                        state_next = OUT4;
                        OUT4 :
                                if(yumi_i == 1'b1)
                                        state_next = CATCH;
                   
endcase
end
end
endmodule

