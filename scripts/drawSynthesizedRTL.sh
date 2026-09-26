yosys -p "
	read_verilog -sv ../rtl/$1.sv;
	hierarchy -top $1;
	proc;
	opt;
	techmap;
	opt;
	abc;
	opt_clean;
	show -format dot -prefix $1
"
echo "$1 synthesis done"
dot -Tpng $1.dot -o $1.png
echo "$1 dot to png done"
