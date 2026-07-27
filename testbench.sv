module bpTestbench;
	parameter int NUM_BP = 8;
	parameter int PC_SIZE = 32;

	logic clk, reset, enable, wasTaken;
	logic[PC_SIZE - 1 : 0] pc;
	logic prediction;

	twoBitBranchPredictor #(
		.NUM_BP(NUM_BP), 
		.PC_SIZE(PC_SIZE)
	) dut (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.wasTaken(wasTaken),
		.pc(pc),
		.prediction(prediction)
	);

	task run_test(input logic test[]);
		reset = 1;
		#10ns reset = 0;
		$write("input: ");
		for (int i = 0; i < test.size(); i++) $write("%b ", test[i]);
		$write("\n");
		for (int i = 0; i < test.size(); i++) begin
			$write("%s ", prediction ? "taken" : "not taken");
			wasTaken = test[i];
			$write("%s\n", prediction == wasTaken ? "HIT" : "MISS");
			@(posedge clk);
			#1;
		end
	endtask

	logic test1[] = '{1,1,1,1,1,1,1,1,1,0}; // for loop	
	
	always #5ns clk = ~clk;

	initial begin
		clk = 0;
		reset = 1;
		enable = 1;
		wasTaken = 0;
		pc = 0;
		
		run_test(test1);
	end
endmodule


