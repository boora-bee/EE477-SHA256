// nonce counter with different starting values
//
//
//
module bsg_nonce_counter 

            ( input                      clk_i
            , input                      reset_i
	    , input	[31:0]		start
            , input                      en_i
            , input        [31:0] limit_i
            , output logic [31:0] counter_o
            , output                     overflowed_o
            );


wire [31:0] counter_plus_1 = counter_o + 1;
assign             overflowed_o   = ( counter_plus_1 == limit_i );
always_ff @ (posedge clk_i)
  if (reset_i)
    counter_o <= start;
  else if (en_i) begin
    if(overflowed_o )   counter_o <= start;
    else                counter_o <= counter_plus_1 ;
  end

endmodule
