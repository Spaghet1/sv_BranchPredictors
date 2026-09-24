module SaturatingCounterTestbench;
	parameter int BITS = 2;

	logic clk, reset, enable, wasTaken;
	logic prediction;

	int simState;

	SaturatingCounter #(.BITS(BITS)) dut (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.wasTaken(wasTaken),
		.prediction(prediction)
	);

	task run_test(input logic test[]);
		
		reset = 1;
		#10ns reset = 0;
		$write("input: ");
		for (int i = 0; i < test.size(); i++) $write("%b ", test[i]);
		$write("\n\n");

		simState = 1;

		for (int i = 0; i < test.size(); i++) begin
			
			$write("dut state: %b\t prediction: %s\n", dut.state, prediction ? "taken" : "not taken");
			$write("sim state: %.2b\t prediction: %s\n", simState, simState > 1 ? "taken" : "not taken");
			$write("actual: %s --> %s\n\n", test[i] ? "taken" : "not taken", prediction == test[i] ? "HIT" : "MISS");
			
			if (32'(dut.state) != simState) begin
				$fatal(1, "state mismatch!!");
			end

			if (test[i] == 0 && simState != 0) begin
				simState -= 1;
			end
			else if (test[i] == 1 && simState != 3) begin
				simState += 1;
			end

			wasTaken = test[i];

			@(posedge clk); // gap between tasks
			@(negedge clk);
		end

	endtask

	logic test1[] = '{1,1,1,1,1,1,1,1,1,0}; // for loop	
	logic test2[] = '{1,0,1,0,1,0,1,0,1,0,1,0,1,0,1}; // alternate
	logic test3[] = '{1,1,1,1,0,0,0,0,0,0,1,1};
	
	always #5ns clk = ~clk;

	initial begin
		clk = 0;
		reset = 1;
		enable = 1;
		wasTaken = 0;

		// run_test(test1);
		// run_test(test2);
		run_test(test3);
		
		$finish;
	end
endmodule


