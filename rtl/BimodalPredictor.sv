// (0,n) predictor

module BimodalPredictor 
#(
	parameter int COUNTER_BITS = 2, 
	parameter int PC_WIDTH = 32,
	parameter int INDEX_BITS = 8
)
(
	input logic clk, reset, enable, wasPrevTaken,
	input logic[PC_WIDTH - 1 : 0] pcAddress,
	output logic prediction
);

	logic[COUNTER_BITS - 1 : 0] counters[1 << INDEX_BITS]; // array of counters
	logic[INDEX_BITS - 1 : 0] prevHash;
	logic[INDEX_BITS - 1 : 0] currHash;

	function automatic logic[COUNTER_BITS - 1 : 0] updateCounter(input logic[COUNTER_BITS - 1 : 0] prevState, input logic wasTaken);
		if (wasTaken && prevState != '1) begin
			updateCounter = prevState + 1;
		end
		else if (!wasTaken && prevState != '0) begin
			updateCounter = prevState - 1;
		end
	endfunction

	always_ff @(posedge clk) begin
		if (reset) begin
			foreach (counters[i]) begin
				counters[i] <= (1 << (COUNTER_BITS - 1)) - 1;
			end
		end

		else if (enable) begin
			counters[prevHash] <= updateCounter(counters[currHash], wasPrevTaken);
			prevHash <= currHash;
		end
	end

	assign currHash = pcAddress[INDEX_BITS + 2 - 1 : 2]; // assume pc addresses are 4 byte aligned
	assign prediction = counters[currHash][COUNTER_BITS - 1];

endmodule
	
