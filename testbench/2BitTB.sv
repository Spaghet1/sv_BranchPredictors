`include "../rtl/SaturatedCounter.sv"

module TwoBitTB;
	parameter int BITS = 2;

	logic clk, reset, enable, wasTaken;
	logic prediction;

	SaturatedCounter #(.BITS(BITS)) dut (
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
	logic test2[] = '{1,0,1,0,1,0,1,0,1,0,1,0,1,0,1}; // alternate
	
	always #5ns clk = ~clk;

	initial begin
		clk = 0;
		reset = 1;
		enable = 1;
		wasTaken = 0;
		
		run_test(test1);
		run_test(test2);
		
		$finish;
	end
endmodule


