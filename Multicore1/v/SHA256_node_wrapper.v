//sha wrapper
module SHA256_node_wrapper 
        (input                          clk_i
        ,input  logic                   reset_i
        ,input                          en_i
        ,input                          v_i
	,input  [31:0]			nonce_start_i
	,input	[31:0]			nonce_end_i
        ,input                          yumi_i
        ,input  [351:0]      		data_i
        ,output logic                   ready_o
        ,output logic                   v_o
        ,output logic [31:0] 		        data_o
        );


logic core1_en_i,core1_ready_o,core1_v_o,core2_en_i,core2_ready_o,core2_v_o,target_en_i,target_ready_o,target_v_o,check,counter_en_i;
logic [255:0] core1_data_o,core2_data_o; 
wire overflow;
reg     [31:0] nonce,target;
assign target = data_i [31:0];

logic [95:0] core1_data_i;
assign core1_data_i = data_i [95:0]; 
logic [255:0] midstate;
assign midstate = data_i [351:96];
logic [511:0] core2_data_i;
assign core2_data_i = {core1_data_o, midstate};
sha_noncecounter 
nonce_counter   (.clk_i(clk_i)
                 ,.reset_i(reset_i)
		 ,.start(nonce_start_i)
                 ,.en_i(counter_en_i)
                 ,.limit_i(nonce_end_i)
                 ,.counter_o(nonce)
                 ,.overflowed_o(overflow)
                );


        bitcoinSHA256_core
                first_sha       (.clk_i(clk_i)						//fix
                                ,.reset_i(reset_i)					
                                ,.en_i(core1_en_i)					      
                                ,.v_i(v_i)						      
                                ,.yumi_i(core2_ready_o)
                                ,.msg_i(core1_data_i)
                                ,.nonce(nonce)
                                ,.ready_o(core1_ready_o)
                                ,.v_o(core1_v_o)
                                ,.digest_o(core1_data_o)
                                );


         bitcoinSHA256_core2								      //fix
                double_sha      (.clk_i(clk_i)
                                ,.reset_i(reset_i)
                                ,.en_i(core2_en_i)
                                ,.v_i(core1_v_o)
                                ,.yumi_i(target_ready_o)
                                ,.msg_i(core2_data_i)
                                ,.ready_o(core2_ready_o)
                                ,.v_o(core2_v_o)
                                ,.digest_o(core2_data_o)
                                );

        bsg_target_check									      //fix
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

        localparam WAIT = 3'b000;
        localparam CALC1 = 3'b001;
        localparam CALC2 = 3'b010;
        localparam CALC3 = 3'b011;
        localparam DONE = 3'b100;
	
	reg [2:0] state_next;
        reg [2:0] state;
        reg [32:0] nonce_next;
        bsg_dff_en #(.width_p(3))
                state_thingy    (.clock_i(clk_i)
                                ,.data_i(state_next)
                                ,.en_i(1'b1)
                                ,.data_o(state)
                                );


	    always_comb     begin
                case(state)
                        WAIT: begin
                                core1_en_i = 1'b1;
                                ready_o = 1'b1;
                                v_o = 1'b0;
                                core2_en_i = 1'b0;
                                target_en_i = 1'b0;
                                counter_en_i = 1'b0;
                        end

			  CALC1: begin
                                ready_o = 1'b0;
                                v_o = 1'b0;
                                core1_en_i = 1'b1;
                                core2_en_i = 1'b0;
                                target_en_i = 1'b0;
                                counter_en_i = 1'b0;
                                end
			 CALC2: begin
                                ready_o = 1'b0;
                                v_o = 1'b0;
                                core1_en_i = 1'b0;
                                core2_en_i = 1'b1;
                                target_en_i = 1'b0;
                                counter_en_i = 1'b0;
                                end
			CALC3: begin
                                ready_o = 1'b0;
                                v_o = 1'b0;
                                core1_en_i = 1'b0;
                                core2_en_i = 1'b0;
                                target_en_i = 1'b1;
                                counter_en_i = 1'b0;
                                end
			DONE: begin
                                if(check == 1'b0)
                                begin
                                ready_o = 1'b0;
                                v_o     = 1'b0;
                                core1_en_i = 1'b0;
                                counter_en_i = 1'b1;
                                target_en_i = 1'b0;
                                core2_en_i = 1'b0;
                                end
                                else if(check == 1'b1)
                                begin
                                ready_o = 1'b0;
                                v_o     = 1'b1;
                                counter_en_i = 1'b0;
                                data_o = nonce;
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
                                                state_next = CALC1;
                                end

                                CALC1: begin
                                                if(core1_v_o == 1'b1)
                                                state_next = CALC2;
                                end


                                CALC2: begin
                                        if(core2_v_o == 1'b1)
                                                state_next = CALC3;
                                end
                                CALC3: begin
                                                if(target_v_o == 1'b1)
                                                state_next = DONE;
                                end

                                DONE: begin
                                        if (check == 1'b1)
                                        begin
                                        state_next = WAIT;
                                        end
                                        else
                                        begin
                                        state_next = CALC1;
                                        end
                                end
                        endcase
                end
        end
endmodule


