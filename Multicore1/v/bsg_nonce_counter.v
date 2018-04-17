// nonce counter with different starting values
//
//
//
module bsg_nonce_counter #(parameter width_p = -1)

            ( input                      clk_i
            , input                      reset_i
	    , input	[width_p-1:0]		start
            , input                      en_i
            , input        [width_p-1:0] limit_i
            , output logic [width_p-1:0] counter_o
            , output                     overflowed_o
            );


wire [width_p-1:0] counter_plus_1 = counter_o + width_p'(1);
assign             overflowed_o   = ( counter_plus_1 == limit_i );
always_ff @ (posedge clk_i)
  if (reset_i)
    counter_o <= start;
  else if (en_i) begin
    if(overflowed_o )   counter_o <= start;
    else                counter_o <= counter_plus_1 ;
  end

endmodule
