// history shift register for correlating bp

module ShiftRegister #(parameter int WIDTH = 4) 
(
	input logic clk, reset, enable, wasTaken,
	output logic[WIDTH - 1 : 0] history
);

	always_ff @(posedge clk) begin
		if (reset) begin
			history <= '0;
		end
		else if (enable) begin
			history <= {history[WIDTH - 2 : 0], wasTaken};
		end
	end
endmodule
