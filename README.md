# r32
32 bit CPU based on the MIPS instruction set

.
│
├── alu - dataflow (alu.vhd)
│   ├── shifter32 - dataflow (shifter.vhd)
│   └── add_sub - structural (adder.vhd)
│       └── fadd - behavioral (fadd.vhd)
├── cache - behavioral (cache.vhd)
├── clock_multiplier - xilinx (clock_multiplier.vhd)
├── sdram - behavioral (sdram.vhd)
│   ├── tx_data - behavioral (fifo.vhd)
│   ├── rx_data - behavioral (fifo.vhd)
│   └── req_queue - behavioral (fifo.vhd)
└── spartan6.ucf
