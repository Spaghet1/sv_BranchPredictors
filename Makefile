VERILATOR = verilator
VERILATOR_FLAGS = --binary --timing --Wall

2bit:
	$(VERILATOR) $(VERILATOR_FLAGS) testbench/SaturatingCounterTestbench.sv rtl/SaturatingCounter.sv --top-module SaturatingCounterTestbench

clean:
	rm -rf obj_dir
