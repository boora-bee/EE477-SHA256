// This is the message scheduler module that provide Wt value for compression
// 	fucntion
//
// Comments on update:
// 	Modified the state machine and cycle counter update logic, then test
// 	the message scheduler in ModelSim, the result seems to be correct, but
// 	I haven't check the handshake yet
//
// input:
//     M_i:        input message
//     clk_i:         the clock that this module runs on
//     reset_i:     the reset signal for this module
//     v_i:     start to counter cycles
//
// output:
//     Wt_o:        the output Wt value
//
// Last modified on: Thu Mar  1 01:01:36 2018
module SHA256_message_scheduler
    (input  [511:0]	M_i 
    ,input		clk_i
    ,input		reset_i    
    ,input		init_i
    ,output [31:0]	Wt_o 
    );

    // data flow
    reg	[31:0]	word_mem [15:0];
    reg	[31:0]	word_next[15:0];
    reg	[31:0]	wt;

    // control logic
    reg		write_en, ctr_rst, ctr_en;
    reg	[6:0]	ctr_r;
    reg		state_r, state_n;
    reg [31:0]	w_0, w_1, w_9, w_14, s0, s1, w_new;
        
    assign Wt_o = wt;

    // word_mem update
    always @(posedge clk_i)    begin
        if (reset_i) begin
            word_mem[0]		<= 32'b0;
            word_mem[1]		<= 32'b0;
            word_mem[2]		<= 32'b0;
            word_mem[3]		<= 32'b0;
            word_mem[4]		<= 32'b0;
            word_mem[5]		<= 32'b0;
            word_mem[6]		<= 32'b0;
            word_mem[7]		<= 32'b0;
            word_mem[8]		<= 32'b0;
            word_mem[9]		<= 32'b0;
            word_mem[10]	<= 32'b0;
            word_mem[11]	<= 32'b0;
            word_mem[12]	<= 32'b0;
            word_mem[13]	<= 32'b0;
            word_mem[14]	<= 32'b0;
            word_mem[15]	<= 32'b0;
       //     write_en		<= 1'b0;
        end else begin
            if (write_en) begin
                word_mem[0]	<= word_next[0];
                word_mem[1]     <= word_next[1];
                word_mem[2]	<= word_next[2];
                word_mem[3]     <= word_next[3];
                word_mem[4]     <= word_next[4];
                word_mem[5]     <= word_next[5];
                word_mem[6]     <= word_next[6];
                word_mem[7]	<= word_next[7];
                word_mem[8]     <= word_next[8];
                word_mem[9]     <= word_next[9];
                word_mem[10]	<= word_next[10];
                word_mem[11]    <= word_next[11];
                word_mem[12]    <= word_next[12];
                word_mem[13]    <= word_next[13];
                word_mem[14]    <= word_next[14];
                word_mem[15]    <= word_next[15];
            end
        end
    end
    
    always @(*) begin
        w_0 = word_mem[0];
        w_1 = word_mem[1];
        w_9 = word_mem[9];
        w_14 = word_mem[14];
        
        s0 = {w_1[6:0], w_1[31:7]}     ^ {w_1[17:0], w_1[31:18]}     ^ (w_1 >> 3);
        s1 = {w_14[16:0], w_14[31:17]} ^ {w_14[18:0], w_14[31:19]}   ^ (w_14 >> 10);

        w_new = w_0 + s0 + w_9 + s1;
        
        if (init_i) begin
            write_en = 1'b1;
            word_next[15] = M_i[31:0];
            word_next[14] = M_i[63:32];
            word_next[13] = M_i[95:64];
            word_next[12] = M_i[127:96];
            word_next[11] = M_i[159:128];
            word_next[10] = M_i[191:160];
            word_next[9]  = M_i[223:192];
            word_next[8]  = M_i[255:224];
            word_next[7]  = M_i[287:256];
            word_next[6]  = M_i[319:288];
            word_next[5]  = M_i[351:320];
            word_next[4]  = M_i[383:352];
            word_next[3]  = M_i[415:384];
            word_next[2]  = M_i[447:416];
            word_next[1]  = M_i[479:448];
            word_next[0]  = M_i[511:480];
        end else begin
            if (ctr_r > 15) begin
                write_en = 1'b1;
                word_next[15] = w_new;
                word_next[14] = word_mem[15];
		word_next[13] = word_mem[14];
                word_next[12] = word_mem[13];
                word_next[11] = word_mem[12];
                word_next[10] = word_mem[11];
                word_next[9]  = word_mem[10];
                word_next[8]  = word_mem[9];
                word_next[7]  = word_mem[8];
                word_next[6]  = word_mem[7];
                word_next[5]  = word_mem[6];
                word_next[4]  = word_mem[5];
                word_next[3]  = word_mem[4];
                word_next[2]  = word_mem[3];
                word_next[1]  = word_mem[2];
                word_next[0]  = word_mem[1];
            end
        end
    end

    always_comb begin    
        if (ctr_r < 16) begin
            wt <= word_mem[ctr_r[3:0]];
        end else begin
            wt <= w_new;
        end
    end

    // cycle update
    always_ff @(posedge clk_i) begin
        if (reset_i | ctr_rst) begin
             ctr_r = 7'b0;
        end else if (ctr_en) begin
             ctr_r = ctr_r + 1'b1;
        end else begin
             ctr_r = ctr_r;
        end
    end

    // state update
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
             state_r = 1'b0;
        end else begin
             state_r = state_n;
        end
    end

    always_comb begin
        case(state_r)
            1'b0:begin // wait
                ctr_en = 1'b0;
                ctr_rst = 1'b1;
                if (init_i) begin
                    state_n = 1'b1;
                    ctr_en = 1'b1;
                    ctr_rst = 1'b0;
                end
            end

            1'b1:begin // busy
                ctr_en = 1'b1;
                ctr_rst = 1'b0;
                if (ctr_r == 7'b1000000) begin
                    state_n = 1'b0;
                    ctr_en = 1'b0;
                    ctr_rst = 1'b1;
                end
            end
            
            default: begin
                state_n = 1'b0;
            end
        endcase

    end
endmodule
