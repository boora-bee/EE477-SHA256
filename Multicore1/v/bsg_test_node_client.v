/**
 * BSG Test Node Client
 */
module  bsg_test_node_client #(parameter ring_width_p="inv"
                              ,parameter master_p="inv"
                              ,parameter master_id_p="inv"
                              ,parameter client_id_p="inv")
  (input  clk_i
  ,input  reset_i
  ,input  en_i

  ,input                     v_i
  ,input  [ring_width_p-1:0] data_i
  ,output                    ready_o
  
  ,output                    v_o
  ,output [ring_width_p-1:0] data_o
  ,input                     yumi_i
  );


  logic [74:0] data_lo, data_li;

  assign data_li = data_i[74:0];
  assign data_o  = { 4'(client_id_p), 1'b0, data_lo };

  /** INSTANTIATE NODE 0 **/ 
  if ( client_id_p == 0 ) begin

   SHA256_node_multi#( .ring_width_p( ring_width_p - 5 )
                      , .id_p        ( client_id_p ))
      node
        (.clk_i   ( clk_i   )
        ,.reset_i ( reset_i )
        ,.en_i    ( en_i    )
        ,.v_i     ( v_i     )
        ,.data_i  ( data_li )
        ,.ready_o ( ready_o )
        ,.v_o     ( v_o     )
        ,.data_o  ( data_lo )
        ,.yumi_i  ( yumi_i  ));

  end

  /** INSTANTIATE NODE 1 **/
  /*
  else if ( client_id_p == 1 ) begin
		gcd_accelerator #(.ring_width_p( ring_width_p - 5 )
                      , .id_p        ( client_id_p ))
			node
				(.clk_i   ( clk_i   )
        ,.reset_i ( reset_i )
        ,.en_i    ( en_i    )
        ,.v_i     ( v_i     )
        ,.data_i  ( data_li )
        ,.ready_o ( ready_o )
        ,.v_o     ( v_o     )
        ,.data_o  ( data_lo )
        ,.yumi_i  ( yumi_i  ));

  end 

  else if ( client_id_p == 2) begin
 	logic [ring_width_p-1:0] data_llo;
	assign data_lo = data_llo[74:0];
 
     bsg_manycore_client_node #( .ring_width_p( ring_width_p )
                               , .id_p        ( client_id_p ))
       node
         (.clk_i   ( clk_i   )
         ,.reset_i ( reset_i )
         ,.en_i    ( en_i    )
         ,.v_i     ( v_i     )
         ,.data_i  ( data_i )
         ,.ready_o ( ready_o )
         ,.v_o     ( v_o     )
         ,.data_o  ( data_llo)
         ,.yumi_i  ( yumi_i  ));	
	end
*/
endmodule

