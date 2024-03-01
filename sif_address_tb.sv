`timescale 1ns/1ps;

module sif_address_tb;
	
	reg        clk_i;
	reg        rst_i;
	reg [3:0]  tx_add_1_i;
	reg [3:0]  tx_add_2_i;
	reg [3:0]  rx_add_i;
	reg        en_i;
	reg        mode_i;

	wire       spi_clk_o;
	wire       spi_data_o;
	wire       done_o;
	wire       err_o;
	
	// Instantiate dut
	sif_address dut(
	
	.clk_i(clk_i),
	.rst_i(rst_i),
	.tx_add_1_i(tx_add_1_i),
	.tx_add_2_i(tx_add_2_i),
	.rx_add_i(rx_add_i),
	.en_i(en_i),
	.mode_i(mode_i),
	.spi_clk_o(spi_clk_o),
	.spi_data_o(spi_data_o),
	.done_o(done_o),
	.err_o(err_o)
	
	);
	
	parameter HPERIOD = 5;
	parameter ONESHIFT = 240;
	
	// Generate 100M clk
	always begin
	   #HPERIOD clk_i = 1;
	   #HPERIOD clk_i = 0;
	end
	
	// Generate reset signal
	initial begin
	    rst_i = 0;
	    #60
		rst_i = 1;
		#10
		rst_i = 0;
	end
	
	// Begin the test
	initial begin
	    mode_i = 0;
	    #100
		tx_add_1_i = 4'b0000;
		tx_add_2_i = 4'b0000;
		rx_add_i = 4'b0000;
		en_i = 1;
		#50
		en_i = 0;

		
		#ONESHIFT // Wait 12 clks
		
		tx_add_1_i = 4'b0000;
		tx_add_2_i = 4'b1111;
		rx_add_i = 4'b1010;
		en_i = 1;
		#50
		en_i = 0;
		
		#ONESHIFT;
		
		tx_add_1_i = 4'b0001;
		tx_add_2_i = 4'b1110;
		rx_add_i = 4'b0101;
		en_i = 1;
		#100
		en_i = 0;
		
		#ONESHIFT;
		
		tx_add_1_i = 4'b0010;
		tx_add_2_i = 4'b1101;
		rx_add_i = 4'b1001;
		en_i = 1;
		#50
		en_i = 0;
		
		#ONESHIFT;
		
		tx_add_1_i = 4'b0011;
		tx_add_2_i = 4'b1100;
		rx_add_i = 4'b0110;
		en_i = 1;
		#50
		en_i = 0;
		
		#ONESHIFT;
		
		tx_add_1_i = 4'b0100;
		tx_add_2_i = 4'b1000;
		rx_add_i = 4'b1100;
		en_i = 1;
		#50
		en_i = 0;
		
		#ONESHIFT;
		
		tx_add_1_i = 4'b0101;
		tx_add_2_i = 4'b0111;
		rx_add_i = 4'b0011;
		en_i = 1;
		#50
		en_i = 0;
		
		#ONESHIFT;
		
		#1000
		
		$finish;
	end
endmodule

		