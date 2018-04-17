//target checker


module bsg_target_check
        (input                          clk_i
        ,input                          reset_i
        ,input                          en_i
        ,input                          v_i
        ,input                          yumi_i
        ,input  [255:0]      		data_i
	,input  [31:0]			target_i
        ,output logic                   ready_o
        ,output logic                   v_o
        ,output logic 		        data_o
        );


        localparam WAIT = 2'b00;
        localparam CALC = 2'b01;
        localparam DONE = 2'b10;

	wire [31:0] double_sha;
     assign double_sha = data_i [31:0];
     reg [1:0] state, state_next;


bsg_dff_en #(.width_p(2))
   state_thingy(.clock_i(clk_i)
   ,.data_i(state_next)
    ,.en_i(1'b1)
   ,.data_o(state)
    );

             always_comb

                begin
                case(state)
                        WAIT: begin
                                ready_o = 1'b1;
                                v_o = 1'b0;
                        end
			CALC: begin
                                ready_o = 1'b0;
                                v_o = 1'b0;
				if(double_sha < target_i)
				data_o = 1'b1;
				else
				data_o = 1'b0;
			      end
                        DONE: begin
				ready_o = 1'b0;
				v_o = 1'b1;
			      end
		endcase
		end

always @(*)
        begin

        if(reset_i==1)

                state_next = WAIT;

        else
                begin
                        state_next = state;
                case
                        (state)


                        WAIT:
                                if( v_i == 1'b1 )
                                        state_next = CALC;
                        CALC :
                                if(ready_o == 1'b0)
                                        state_next = DONE;
                        DONE:
                                if(v_i)
                                        state_next = WAIT;
endcase
end
end
endmodule




