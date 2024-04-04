# AMBA AXI DESIGN AND VERIFICATION
AMBA AXI 4 protocols design and verification.
A 128X8 byte memory is taken as a slave and the UVM testbench acts as a Master.
Contains 5 channels Write address channel, Write Data channel, Write Response channel, read address channel and read data channel.
Each channel has a valid and ready signal for proper handshaking.
The width of address bus and the data bus is taken as 32 bit.
Supports all the three address burst modes, viz, fixed type, increment type and wrap type.
