//sha wrapper
SHA256_node_wrapper #(parameter ring_width_p = "inv", parameter id_p="inv")
        (input                          clk_i
        ,input  logic                   reset_i
        ,input                          en_i
        ,input                          v_i
	,input				nonce
	,input 				target
        ,input                          yumi_i
        ,input  [ring_width_p-1:0]      data_i
        ,output logic                   ready_o
        ,output logic                   v_o
        ,output [ring_width_p-1:0]      data_o
        );


logic [31:0] counter_limit;
assign counter_limit = 32'b11111111111111111111111111111111;
logic overflow;
bsg_counter_en_overflow #(.width_p(32))
nonce_counter   (.clk_i(clk_i)
                 ,.reset_i(reset_i)
                 ,.en_i(counter_en_i)
                 ,.limit_i(counter_limit)
                 ,.counter_o(nonce)
                 ,.overflowed_o(overflow)
                );


        bitcoinSHA256_core
                first_sha       (.clk_i(clk_i)
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
                walmart         (.clk_i(clk_i)
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



