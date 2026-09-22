module SaturatedCounter #(parameter int BITS = 2) 
(
	input logic clk, reset, enable, wasTaken,
	output logic prediction
);

	logic[BITS - 1 : 0] state;

	always_ff @(posedge clk) begin
		if (reset) begin
			state <= (1 << (BITS - 1)) - 1; // "weakest" not taken
		end
		else if (enable) begin
			if (wasTaken && state != '1) begin
				state <= state + 1;
			end
			else if (!wasTaken && state != '0) begin
				state <= state - 1;
			end
		end
	end
	
	assign prediction = state[BITS - 1];
endmodule

