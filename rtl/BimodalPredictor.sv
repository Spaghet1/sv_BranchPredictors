// (0,n) predictor

module BimodalPredictor 
#(
	parameter int COUNTER_BITS = 2, 
	parameter int PC_WIDTH = 64,
	parameter int INDEX_BITS = 8
)
(
	input logic clk, reset, pcEnable, counterEnable, wasPrevTaken,
	input logic[PC_WIDTH - 1 : 0] pcAddress,
	output logic prediction
);

	localparam int NUM_ENTRIES = 1 << INDEX_BITS;
	localparam logic[COUNTER_BITS - 1 : 0] RESET_VAL = (1 << (COUNTER_BITS - 1)) - 1;

	logic[COUNTER_BITS - 1 : 0] counters[NUM_ENTRIES]; // array of counters
	logic[INDEX_BITS - 1 : 0] prevHash;
	logic[INDEX_BITS - 1 : 0] currHash;

	function automatic logic[COUNTER_BITS - 1 : 0] updateCounter(input logic[COUNTER_BITS - 1 : 0] prevState, input logic wasTaken);

		if (wasTaken && prevState != '1) begin
			updateCounter = prevState + 1;
		end
		else if (!wasTaken && prevState != '0) begin
			updateCounter = prevState - 1;
		end
		else begin
			updateCounter = prevState;
		end
	endfunction

	always_ff @(posedge clk) begin
		if (reset) begin
			for (int i = 0; i < NUM_ENTRIES; i++) begin
				counters[i] <= RESET_VAL; 
			end
			prevHash <= '0;
		end
		else begin
			if (pcEnable) begin
				prevHash <= currHash;
			end
			if (counterEnable) begin
				counters[prevHash] <= updateCounter(counters[prevHash], wasPrevTaken);
			end
		end
	end

	assign currHash = pcAddress[INDEX_BITS + 2 - 1 : 2]; // assume pc addresses are 4 byte aligned
	assign prediction = counters[currHash][COUNTER_BITS - 1];

endmodule
