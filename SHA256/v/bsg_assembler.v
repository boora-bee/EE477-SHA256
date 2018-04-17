//this is an assembler for sha
//


module bsg_assembler #(parameter ring_width_p="inv"           ,parameter id_p="inv")
  (input  clk_i
  ,input  reset_i
  ,input  en_i

  ,input                     v_i

  ,input  [ring_width_p -1 :0] data_i
  ,output            logic        ready_o

  ,output logic          	v_o
  ,output reg	[255:0] 	data_o


 

  ,input                     yumi_i
  );




//	localparam Ks = {
//		32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
//		32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
//		32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
//		32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
//		32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
//		32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
//		32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
//		32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
//		32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
//		32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
//		32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
//		32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
//		32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
//		32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
//		32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
//	32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

//logic [31:0] a_i;
//logic [31:0] b_i;

//assign a_i = data_i [31:0];
//assign b_i = data_i [63:32];

wire [63:0] join_i;

wire [63:0] in1_out;
wire [63:0] in2_out;
wire [63:0] in3_out;
wire [63:0] in4_out;



assign join_i = data_i;  //first pass
//assign data_o = {in4_out,in3_out,in2_out,in1_out};			//input to sha module change from data_o



//assign data_o = join_i [63:0];   // change this
localparam IN1 = 3'b000;
localparam IN2 = 3'b001;
localparam IN3 = 3'b010;
localparam IN4 = 3'b011;
localparam DONE = 3'b100;

reg [2:0] state_next;
reg [2:0] state;

logic en1_i; 
logic en2_i;
logic en3_i;
logic en4_i;


bsg_dff_en #(.width_p(64))
in1	    (.clock_i(clk_i)
            ,.data_i(join_i)
            ,.en_i(en1_i)
            ,.data_o(in1_out)
            );


bsg_dff_en #(.width_p(64))
in2         (.clock_i(clk_i)
            ,.data_i(join_i)
            ,.en_i(en2_i)
            ,.data_o(in2_out)
            );

bsg_dff_en #(.width_p(64))
in3         (.clock_i(clk_i)
            ,.data_i(join_i)
            ,.en_i(en3_i)
            ,.data_o(in3_out)
            );

bsg_dff_en #(.width_p(64))
in4         (.clock_i(clk_i)
            ,.data_i(join_i)
            ,.en_i(en4_i)
            ,.data_o(in4_out)
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

IN1:

	begin
	ready_o = 1'b1;
	v_o = 1'b0;
	en1_i = 1'b1;
	en2_i = 1'b0;
	en3_i = 1'b0;
	en4_i = 1'b0;
	end

IN2:

	begin
        ready_o = 1'b1;
        v_o = 1'b0;
	en1_i = 1'b0;
        en2_i = 1'b1;
	en3_i = 1'b0;		
	en4_i = 1'b0;
        end

IN3:

        begin
        ready_o = 1'b1;
        v_o = 1'b0;
	en1_i = 1'b0;
	en2_i = 1'b0;
        en3_i = 1'b1;
	en4_i = 1'b0;
        end


IN4:

        begin
        ready_o = 1'b1;
        v_o = 1'b0;
	en1_i = 1'b0;	
	en2_i = 1'b0;
	en3_i = 1'b0;
        en4_i = 1'b1;
        end

DONE:
	begin
	v_o = 1'b1;
	ready_o =1'b0;
	en1_i = 1'b0;
        en2_i = 1'b0;
        en3_i = 1'b0;
        en4_i = 1'b0;

	data_o = {in4_out,in3_out,in2_out,in1_out};

//	assign data_o = {in4_out,in3_out,in2_out,in1_out};

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
					state_next = IN3;
			IN3 :
				if(v_i == 1'b1)
					state_next = IN4;
			IN4 : 	
				if(v_i == 1'b1)
					state_next = DONE;
			DONE:
				if(yumi_i & v_i)
					state_next = IN1;
endcase
end
end
endmodule


