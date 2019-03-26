/*
----------------------------------------------------------------------------
--  uart_rx.v
--	UART receiver module
--	Version 1.0
--
--  Copyright (C) 2019 Fares Mehanna
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------
*/
/* Machine-generated using Migen */
module top(
	input rx_port,
	input rx_ack,
	output reg [7:0] rx_data,
	output reg rx_ready,
	input sys_clk,
	input sys_rst
);

reg [13:0] rx_counter = 14'd10415;
reg rx_strobe = 1'd0;
reg [2:0] rx_bitno = 3'd0;
reg [2:0] state = 3'd0;
reg [2:0] next_state;
reg [13:0] rx_counter_next_value0;
reg rx_counter_next_value_ce0;
reg [7:0] rx_data_next_value1;
reg rx_data_next_value_ce1;
reg [2:0] rx_bitno_next_value2;
reg rx_bitno_next_value_ce2;
reg rx_ready_next_value3;
reg rx_ready_next_value_ce3;


// Adding a dummy event (using a dummy signal 'dummy_s') to get the simulator
// to run the combinatorial process once at the beginning.
// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on


// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	next_state <= 3'd0;
	rx_counter_next_value0 <= 14'd0;
	rx_counter_next_value_ce0 <= 1'd0;
	rx_data_next_value1 <= 8'd0;
	rx_data_next_value_ce1 <= 1'd0;
	rx_bitno_next_value2 <= 3'd0;
	rx_bitno_next_value_ce2 <= 1'd0;
	rx_ready_next_value3 <= 1'd0;
	rx_ready_next_value_ce3 <= 1'd0;
	next_state <= state;
	case (state)
		1'd1: begin
			if (rx_strobe) begin
				next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (rx_strobe) begin
				rx_data_next_value1 <= {rx_port, rx_data[7:1]};
				rx_data_next_value_ce1 <= 1'd1;
				rx_bitno_next_value2 <= (rx_bitno + 1'd1);
				rx_bitno_next_value_ce2 <= 1'd1;
				if ((rx_bitno == 3'd7)) begin
					next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if ((rx_strobe & rx_port)) begin
				rx_ready_next_value3 <= 1'd1;
				rx_ready_next_value_ce3 <= 1'd1;
				next_state <= 3'd4;
			end
		end
		3'd4: begin
			if (rx_ack) begin
				rx_ready_next_value3 <= 1'd0;
				rx_ready_next_value_ce3 <= 1'd1;
				next_state <= 1'd0;
			end
		end
		default: begin
			if ((~rx_port)) begin
				rx_counter_next_value0 <= 13'd5208;
				rx_counter_next_value_ce0 <= 1'd1;
				next_state <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end

always @(posedge sys_clk) begin
	rx_strobe <= (rx_counter == 1'd1);
	if ((rx_counter == 1'd0)) begin
		rx_counter <= 14'd10415;
	end else begin
		rx_counter <= (rx_counter - 1'd1);
	end
	state <= next_state;
	if (rx_counter_next_value_ce0) begin
		rx_counter <= rx_counter_next_value0;
	end
	if (rx_data_next_value_ce1) begin
		rx_data <= rx_data_next_value1;
	end
	if (rx_bitno_next_value_ce2) begin
		rx_bitno <= rx_bitno_next_value2;
	end
	if (rx_ready_next_value_ce3) begin
		rx_ready <= rx_ready_next_value3;
	end
	if (sys_rst) begin
		rx_data <= 8'd0;
		rx_ready <= 1'd0;
		rx_counter <= 14'd10415;
		rx_strobe <= 1'd0;
		rx_bitno <= 3'd0;
		state <= 3'd0;
	end
end

endmodule