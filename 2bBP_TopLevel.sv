module twoBitBranchPredictor 
	(
	input logic clk, reset, enable, wasTaken,
	output logic prediction
	);

	typedef enum logic[1:0] {
		SNT = 2'b00, 
		WNT = 2'b01, 
		WT = 2'b10, 
		ST = 2'b11
	} state_t;

	state_t state;

	always_ff @(posedge clk) begin
		if (reset) begin
			state = WNT;
		end
		else if (enable) begin
			case (state)
				SNT: state <= wasTaken ? WNT : SNT;
				WNT: state <= wasTaken ? WT : SNT;
				WT: state <= wasTaken ? ST : WNT;
				ST: state <= wasTaken ? ST : WT;
			endcase
		end
	end

	always_comb begin
		output = state[1];
	end
endmodule

