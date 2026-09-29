module BimodalPredictorTestbench;

	localparam int COUNTER_BITS = 2;
	localparam int PC_WIDTH = 32;
	localparam int INDEX_BITS = 3;

	logic clk, reset, pcEnable, counterEnable, wasTaken;
	logic prediction;
	logic [PC_WIDTH - 1 : 0] pcAddr;

	BimodalPredictor #(
		.COUNTER_BITS(COUNTER_BITS),
		.PC_WIDTH(PC_WIDTH),
		.INDEX_BITS(INDEX_BITS)
	) dut (
		.clk(clk),
		.reset(reset),
		.pcEnable(pcEnable),
		.counterEnable(counterEnable),
		.wasPrevTaken(wasTaken),
		.pcAddress(pcAddr),
		.prediction(prediction)
	);

	always #5ns clk = ~clk;

	/*
	task run_trace(input logic[PC_WIDTH - 1 : 0] PC, input logic tbWasTaken, input logic expected);
		@(negedge clk);
		wasTaken = tbWasTaken;
		pcAddr = PC;
		#1ns;

		if (prediction !== expected) begin
			$fatal(1, "prediction mismatch");
		end
		$write("PC address: %x", PC);
		foreach (dut.counters[i]) begin
			$write(" %b", dut.counters[i]);
		end
		$write("\n");
	
		enable = 1'b1;
		@(posedge clk);
		@(negedge clk);
		enable = 1'b0;
	endtask
	*/

	task get_prediction(input logic[PC_WIDTH - 1 : 0] PC, input logic expected);
		pcAddr = PC;
		pcEnable = 1'b1;
		@(posedge clk);
		@(negedge clk);
		pcEnable = 1'b0;

		if (prediction !== expected) begin
			$fatal(1, "prediction mismatch");
		end
		$write("PC address: %x\t prediction: %b\t expected: %b\n\n", PC, prediction, expected);

	endtask

	task update_counter(input logic actual);
		$write("updating last branch with %b\n", actual);
		$write("Before\n");
		foreach (dut.counters[i]) begin
			$write(" %b", dut.counters[i]);
		end
		$write("\n");
		wasTaken = actual;
		counterEnable = 1'b1;
		@(posedge clk);
		@(negedge clk);
		counterEnable = 1'b0;
		$write("After\n");
		foreach (dut.counters[i]) begin
			$write(" %b", dut.counters[i]);
		end
		$write("\n\n");
	endtask

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, BimodalPredictorTestbench);
		clk = '0;
		reset = '1;
		pcEnable = '0;
		counterEnable = '0;
		wasTaken = '0;
		pcAddr = '0;

		@(posedge clk);
		@(negedge clk);
		reset = 0;
		
		get_prediction(32'h0, 0);
		update_counter(1);
		get_prediction(32'h0, 1);
		update_counter(1);
		get_prediction(32'h4, 0); // another counter
		update_counter(1);
		get_prediction(32'h4, 1);
		get_prediction(32'h20, 1); // different predictor
		update_counter(0);
		update_counter(0);
		get_prediction(32'h0, 0); // aliased

		$finish;
	end
endmodule
