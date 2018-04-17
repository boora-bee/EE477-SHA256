// This is the module that gives constant data Kt to the compression module
//
// input: 
// 	addr: the address for the output Kt value
//	
// output:
// 	Kt_o: the Kt value that will be used in compression module
module SHA256_Kt_mem # (parameter core_size = "inv")
	(input 	[5:0]	addr
	,output	[31:0]	Kt_o
	);

	reg [6:0]	addr_r;
	reg [31:0]	Kt_r;
	
	assign Kt_o = Kt_r;

	always @(*) begin
		case(addr)
			6'b000000: Kt_r = 32'h428a2f98;
        		6'b000001: Kt_r = 32'h71374491;
        		6'b000010: Kt_r = 32'hb5c0fbcf;
        		6'b000011: Kt_r = 32'he9b5dba5;
        		6'b000100: Kt_r = 32'h3956c25b;
        		6'b000101: Kt_r = 32'h59f111f1;
        		6'b000110: Kt_r = 32'h923f82a4;
        		6'b000111: Kt_r = 32'hab1c5ed5;
        		6'b001000: Kt_r = 32'hd807aa98;
        		6'b001001: Kt_r = 32'h12835b01;
        		6'b001010: Kt_r = 32'h243185be;
        		6'b001011: Kt_r = 32'h550c7dc3;
        		6'b001100: Kt_r = 32'h72be5d74;
        		6'b001101: Kt_r = 32'h80deb1fe;
        		6'b001110: Kt_r = 32'h9bdc06a7;
        		6'b001111: Kt_r = 32'hc19bf174;
        		6'b010000: Kt_r = 32'he49b69c1;
        		6'b010001: Kt_r = 32'hefbe4786;
        		6'b010010: Kt_r = 32'h0fc19dc6;
        		6'b010011: Kt_r = 32'h240ca1cc;
        		6'b010100: Kt_r = 32'h2de92c6f;
        		6'b010101: Kt_r = 32'h4a7484aa;
        		6'b010110: Kt_r = 32'h5cb0a9dc;
        		6'b010111: Kt_r = 32'h76f988da;
        		6'b011000: Kt_r = 32'h983e5152;
        		6'b011001: Kt_r = 32'ha831c66d;
        		6'b011010: Kt_r = 32'hb00327c8;
        		6'b011011: Kt_r = 32'hbf597fc7;
        		6'b011100: Kt_r = 32'hc6e00bf3;
        		6'b011101: Kt_r = 32'hd5a79147;
        		6'b011110: Kt_r = 32'h06ca6351;
        		6'b011111: Kt_r = 32'h14292967;
        		6'b100000: Kt_r = 32'h27b70a85;
        		6'b100001: Kt_r = 32'h2e1b2138;
        		6'b100010: Kt_r = 32'h4d2c6dfc;
        		6'b100011: Kt_r = 32'h53380d13;
        		6'b100100: Kt_r = 32'h650a7354;
        		6'b100101: Kt_r = 32'h766a0abb;
        		6'b100110: Kt_r = 32'h81c2c92e;
        		6'b100111: Kt_r = 32'h92722c85;
        		6'b101000: Kt_r = 32'ha2bfe8a1;
        		6'b101001: Kt_r = 32'ha81a664b;
        		6'b101010: Kt_r = 32'hc24b8b70;
        		6'b101011: Kt_r = 32'hc76c51a3;
        		6'b101100: Kt_r = 32'hd192e819;
        		6'b101101: Kt_r = 32'hd6990624;
        		6'b101110: Kt_r = 32'hf40e3585;
        		6'b101111: Kt_r = 32'h106aa070;
        		6'b110000: Kt_r = 32'h19a4c116;
        		6'b110001: Kt_r = 32'h1e376c08;
        		6'b110010: Kt_r = 32'h2748774c;
        		6'b110011: Kt_r = 32'h34b0bcb5;
        		6'b110100: Kt_r = 32'h391c0cb3;
        		6'b110101: Kt_r = 32'h4ed8aa4a;
        		6'b110110: Kt_r = 32'h5b9cca4f;
        		6'b110111: Kt_r = 32'h682e6ff3;
        		6'b111000: Kt_r = 32'h748f82ee;
        		6'b111001: Kt_r = 32'h78a5636f;
        		6'b111010: Kt_r = 32'h84c87814;
        		6'b111011: Kt_r = 32'h8cc70208;
        		6'b111100: Kt_r = 32'h90befffa;
        		6'b111101: Kt_r = 32'ha4506ceb;
        		6'b111110: Kt_r = 32'hbef9a3f7;
			6'b111111: Kt_r = 32'hc67178f2;	
		endcase
	end
endmodule
