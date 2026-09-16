module twoBitBranchPredictor 
#(
	parameter int NUM_BP = 32,
	parameter int PC_SIZE = 32
)
(
	input logic clk, reset, enable, wasTaken,
	input logic[PC_SIZE - 1:0] pc,
	output logic prediction
);

	typedef enum logic[1:0] {
		SNT = 2'b00, 
		WNT = 2'b01, 
		WT = 2'b10, 
		ST = 2'b11
	} state_t;

	state_t[NUM_BP - 1 : 0] state;
	logic[$clog2(NUM_BP) - 1:0] index;

	always_ff @(posedge clk) begin
		if (reset) begin
			for (int i = 0; i < NUM_BP; i++) begin
				state[i] <= WNT;
			end
		end
		else if (enable) begin
			case (state[index])
				SNT: state[index] <= wasTaken ? WNT : SNT;
				WNT: state[index] <= wasTaken ? WT : SNT;
				WT: state[index] <= wasTaken ? ST : WNT;
				ST: state[index] <= wasTaken ? ST : WT;
			endcase
		end
	end

	always_comb begin
		index = pc % NUM_BP;
		prediction = state[index][1];
	end
endmodule

