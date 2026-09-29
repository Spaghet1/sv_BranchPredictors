VERILATOR = verilator
VERILATOR_FLAGS = --binary --timing --trace -Wall -Wno-fatal

2bit-test:
	$(VERILATOR) $(VERILATOR_FLAGS) testbench/SaturatingCounterTestbench.sv rtl/SaturatingCounter.sv --top-module SaturatingCounterTestbench

bimodal-test:
	$(VERILATOR) $(VERILATOR_FLAGS) testbench/BimodalPredictorTestbench.sv rtl/BimodalPredictor.sv --top-module BimodalPredictorTestbench
clean:
	rm -rf obj_dir
