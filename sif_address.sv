
module sif_address(
	input			clk_i,
	input			rst_i,
	
	input logic[3:0]		tx_add_1_i,
	input logic[3:0]		tx_add_2_i,
	input logic[3:0]		rx_add_i,
	
	input 					en_i,
	input					mode_i, //1 = continuity check, 0 = capacitive check
	
	output					spi_clk_o,
	output					spi_data_o,	
	
	output					done_o,
	output			      	err_o,
	
	output logic[11:0]     	spi_reg_mon
	);
	
	logic clk_div;
	
	// Intialize divided clk to zero when state reaches Idle.
	always_ff @(posedge clk_i)
	   if (state == Idle) clk_div <= 0;
	   else clk_div <= ~clk_div;
	
	// These are the states that will be used.
	typedef enum logic [2:0]
		{	Idle, 
			Shift,
			Done		} state_e;	
	state_e	state, next;
	
	// Register input and output data.
	logic [3:0] 	tx_add_1, tx_add_2, rx_add;
	logic [11:0]	spi_reg;	
	assign spi_data_o = spi_reg[0];
	
	logic [$clog2(12):0]	count;
	
	logic error_input, error_reg;
	
	assign error_input = 
		state == Idle 				&& 
		tx_add_1_i == tx_add_2_i 	&& 
		mode_i == 0;
		
		// Seq logic for errors. When reset or shifting is done, clear error flag.
		// Error is registered under the following conditions:
		// state is Idle, both tx addr are same and we are NOT in cont mode.
		// The error_input is used to determine the next state when current state is Idle.
	always_ff @(posedge clk_i)
		if(rst_i || state == Done)	error_reg <= 0;
		else if(error_input)		error_reg <= 1;
		
	logic do_shift;
	assign do_shift = (state == Shift && clk_div == 1);
	
	// error_input is used to determine next state when in Idle. If we have error_input (see above)
	// then next state will be Done otherwise Shift.
	// We enter the shift state when our count function (see below) has reached 11 and continue in
	// the shift state until count == 11. The Done state is reached upon error or count == 11.	
	always_comb
		case(state)
			Idle:					if(en_i)		next	= 	error_input	?				Done 	:	Shift;
									else			next 	=								Idle;
			Shift:					if(do_shift)	next	=	count == 11 ?				Done 	:	Shift;
									else			next	=								Shift;
			Done:									next	=								Idle;	
			default:								next	=								Idle;
		endcase
		
	assign done_o = state == Done;
	assign err_o = error_reg;
	assign spi_clk_o = clk_div && state == Shift;	
	
	always_ff @(posedge clk_i) begin
		if(rst_i)	                      spi_reg   	<= '0;
		else if(state == Idle)            spi_reg 	    <= {tx_add_1_i, tx_add_2_i, rx_add_i};
		else if(do_shift)			      spi_reg		<= {0, spi_reg[10:1]};	
	end

	always_ff @(posedge clk_i)
		if(state == Idle)		count <= '0;
		else if(do_shift)		count <= count + 1'b1;

	always_ff @(posedge clk_i)
		if(rst_i)	state <= Idle;
		else		state <= next;
		
endmodule
