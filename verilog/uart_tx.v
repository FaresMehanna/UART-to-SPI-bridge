/*
----------------------------------------------------------------------------
--  uart_tx.v
--	UART transmitter module
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
	input [7:0] tx_data,
	input tx_ack,
	output reg tx_port,
	output reg tx_ready,
	input sys_clk,
	input sys_rst
);

reg [13:0] tx_counter = 14'd0;
reg tx_strobe = 1'd0;
reg [2:0] tx_bitno = 3'd0;
reg [7:0] tx_latch = 8'd0;
reg [1:0] state = 2'd0;
reg [1:0] next_state;
reg [13:0] tx_counter_next_value0;
reg tx_counter_next_value_ce0;
reg tx_ready_next_value1;
reg tx_ready_next_value_ce1;
reg [7:0] tx_latch_next_value2;
reg tx_latch_next_value_ce2;
reg tx_port_next_value3;
reg tx_port_next_value_ce3;
reg [2:0] tx_bitno_next_value4;
reg tx_bitno_next_value_ce4;


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
	next_state <= 2'd0;
	tx_counter_next_value0 <= 14'd0;
	tx_counter_next_value_ce0 <= 1'd0;
	tx_ready_next_value1 <= 1'd0;
	tx_ready_next_value_ce1 <= 1'd0;
	tx_latch_next_value2 <= 8'd0;
	tx_latch_next_value_ce2 <= 1'd0;
	tx_port_next_value3 <= 1'd0;
	tx_port_next_value_ce3 <= 1'd0;
	tx_bitno_next_value4 <= 3'd0;
	tx_bitno_next_value_ce4 <= 1'd0;
	next_state <= state;
	case (state)
		1'd1: begin
			if (tx_strobe) begin
				tx_port_next_value3 <= 1'd0;
				tx_port_next_value_ce3 <= 1'd1;
				next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (tx_strobe) begin
				tx_port_next_value3 <= tx_latch[0];
				tx_port_next_value_ce3 <= 1'd1;
				tx_latch_next_value2 <= {1'd0, tx_latch[7:1]};
				tx_latch_next_value_ce2 <= 1'd1;
				tx_bitno_next_value4 <= (tx_bitno + 1'd1);
				tx_bitno_next_value_ce4 <= 1'd1;
				if ((tx_bitno == 3'd7)) begin
					next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if (tx_strobe) begin
				tx_port_next_value3 <= 1'd1;
				tx_port_next_value_ce3 <= 1'd1;
				tx_ready_next_value1 <= 1'd1;
				tx_ready_next_value_ce1 <= 1'd1;
				next_state <= 1'd0;
			end
		end
		default: begin
			if (tx_ack) begin
				tx_counter_next_value0 <= 14'd10415;
				tx_counter_next_value_ce0 <= 1'd1;
				tx_ready_next_value1 <= 1'd0;
				tx_ready_next_value_ce1 <= 1'd1;
				tx_latch_next_value2 <= tx_data;
				tx_latch_next_value_ce2 <= 1'd1;
				next_state <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end

always @(posedge sys_clk) begin
	tx_strobe <= (tx_counter == 1'd1);
	if ((tx_counter == 1'd0)) begin
		tx_counter <= 14'd10415;
	end else begin
		tx_counter <= (tx_counter - 1'd1);
	end
	state <= next_state;
	if (tx_counter_next_value_ce0) begin
		tx_counter <= tx_counter_next_value0;
	end
	if (tx_ready_next_value_ce1) begin
		tx_ready <= tx_ready_next_value1;
	end
	if (tx_latch_next_value_ce2) begin
		tx_latch <= tx_latch_next_value2;
	end
	if (tx_port_next_value_ce3) begin
		tx_port <= tx_port_next_value3;
	end
	if (tx_bitno_next_value_ce4) begin
		tx_bitno <= tx_bitno_next_value4;
	end
	if (sys_rst) begin
		tx_port <= 1'd1;
		tx_ready <= 1'd1;
		tx_counter <= 14'd0;
		tx_strobe <= 1'd0;
		tx_bitno <= 3'd0;
		tx_latch <= 8'd0;
		state <= 2'd0;
	end
end

endmodule