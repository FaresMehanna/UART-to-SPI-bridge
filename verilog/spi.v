/*
----------------------------------------------------------------------------
--  spi.v
--	SPI module
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
	input [3:0] word_length,
	input [1:0] ss_select,
	input tx_start,
	input rx_start,
	input rx_ack,
	input [15:0] tx_data,
	input miso,
	output [15:0] rx_data,
	output reg tx_ready,
	output reg rx_ready,
	output reg rx_data_ready,
	input lsb_first,
	output reg sck,
	output reg mosi,
	output reg ss_s,
	output reg ss_s_1,
	output reg ss_s_2,
	output reg ss_s_3,
	input sys_clk,
	input sys_rst
);

reg rising_edge = 1'd1;
reg [1:0] clk_counter = 2'd3;
wire tr_strobe_high;
wire tr_strobe_low;
reg [3:0] bitno = 4'd0;
reg [1:0] ss_latch = 2'd0;
reg [3:0] word_len_latch = 4'd0;
reg operation_tx_latch = 1'd0;
reg [15:0] rx_buffer = 16'd0;
reg [15:0] tx_buffer = 16'd0;
reg [1:0] state = 2'd0;
reg [1:0] next_state;
reg [15:0] tx_buffer_t_next_value0;
reg tx_buffer_t_next_value_ce0;
reg [1:0] ss_latch_t_next_value1;
reg ss_latch_t_next_value_ce1;
reg [3:0] word_len_latch_t_next_value2;
reg word_len_latch_t_next_value_ce2;
reg operation_tx_latch_t_next_value3;
reg operation_tx_latch_t_next_value_ce3;
reg tx_ready_t_next_value4;
reg tx_ready_t_next_value_ce4;
reg rx_ready_t_next_value5;
reg rx_ready_t_next_value_ce5;
reg rx_data_ready_f_next_value0;
reg rx_data_ready_f_next_value_ce0;
reg [15:0] rx_buffer_f_next_value1;
reg rx_buffer_f_next_value_ce1;
reg next_value;
reg next_value_ce;
reg mosi_t_next_value6;
reg mosi_t_next_value_ce6;
reg [3:0] bitno_t_next_value7;
reg bitno_t_next_value_ce7;
reg array_muxed = 1'd0;


// Adding a dummy event (using a dummy signal 'dummy_s') to get the simulator
// to run the combinatorial process once at the beginning.
// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign tr_strobe_high = (clk_counter == 1'd0);
assign tr_strobe_low = (clk_counter == 2'd2);
assign rx_data = rx_buffer;

// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	next_state <= 2'd0;
	tx_buffer_t_next_value0 <= 16'd0;
	tx_buffer_t_next_value_ce0 <= 1'd0;
	ss_latch_t_next_value1 <= 2'd0;
	ss_latch_t_next_value_ce1 <= 1'd0;
	word_len_latch_t_next_value2 <= 4'd0;
	word_len_latch_t_next_value_ce2 <= 1'd0;
	operation_tx_latch_t_next_value3 <= 1'd0;
	operation_tx_latch_t_next_value_ce3 <= 1'd0;
	tx_ready_t_next_value4 <= 1'd0;
	tx_ready_t_next_value_ce4 <= 1'd0;
	rx_ready_t_next_value5 <= 1'd0;
	rx_ready_t_next_value_ce5 <= 1'd0;
	rx_data_ready_f_next_value0 <= 1'd0;
	rx_data_ready_f_next_value_ce0 <= 1'd0;
	rx_buffer_f_next_value1 <= 16'd0;
	rx_buffer_f_next_value_ce1 <= 1'd0;
	next_value <= 1'd0;
	next_value_ce <= 1'd0;
	mosi_t_next_value6 <= 1'd0;
	mosi_t_next_value_ce6 <= 1'd0;
	bitno_t_next_value7 <= 4'd0;
	bitno_t_next_value_ce7 <= 1'd0;
	next_state <= state;
	case (state)
		1'd1: begin
			if (((rising_edge & tr_strobe_high) | ((~rising_edge) & tr_strobe_low))) begin
				next_value <= 1'd0;
				next_value_ce <= 1'd1;
				if (lsb_first) begin
					rx_buffer_f_next_value1 <= {miso, rx_buffer[15:1]};
					rx_buffer_f_next_value_ce1 <= 1'd1;
				end else begin
					rx_buffer_f_next_value1 <= {rx_buffer[14:0], miso};
					rx_buffer_f_next_value_ce1 <= 1'd1;
				end
				if (lsb_first) begin
					mosi_t_next_value6 <= tx_buffer[0];
					mosi_t_next_value_ce6 <= 1'd1;
					tx_buffer_t_next_value0 <= {1'd0, tx_buffer[15:1]};
					tx_buffer_t_next_value_ce0 <= 1'd1;
				end else begin
					mosi_t_next_value6 <= tx_buffer[15];
					mosi_t_next_value_ce6 <= 1'd1;
					tx_buffer_t_next_value0 <= {tx_buffer[14:0], 1'd0};
					tx_buffer_t_next_value_ce0 <= 1'd1;
				end
				bitno_t_next_value7 <= (bitno + 1'd1);
				bitno_t_next_value_ce7 <= 1'd1;
				if ((bitno == word_len_latch)) begin
					next_state <= 2'd2;
					if ((~operation_tx_latch)) begin
						rx_data_ready_f_next_value0 <= 1'd1;
						rx_data_ready_f_next_value_ce0 <= 1'd1;
					end
				end
			end
		end
		2'd2: begin
			next_value <= 1'd1;
			next_value_ce <= 1'd1;
			bitno_t_next_value7 <= 1'd0;
			bitno_t_next_value_ce7 <= 1'd1;
			if (operation_tx_latch) begin
				next_state <= 1'd0;
			end else begin
				if (rx_ack) begin
					next_state <= 1'd0;
					rx_data_ready_f_next_value0 <= 1'd0;
					rx_data_ready_f_next_value_ce0 <= 1'd1;
				end
			end
		end
		default: begin
			if ((tx_start | rx_start)) begin
				tx_buffer_t_next_value0 <= tx_data;
				tx_buffer_t_next_value_ce0 <= 1'd1;
				ss_latch_t_next_value1 <= ss_select;
				ss_latch_t_next_value_ce1 <= 1'd1;
				word_len_latch_t_next_value2 <= word_length;
				word_len_latch_t_next_value_ce2 <= 1'd1;
				operation_tx_latch_t_next_value3 <= tx_start;
				operation_tx_latch_t_next_value_ce3 <= 1'd1;
				tx_ready_t_next_value4 <= 1'd0;
				tx_ready_t_next_value_ce4 <= 1'd1;
				rx_ready_t_next_value5 <= 1'd0;
				rx_ready_t_next_value_ce5 <= 1'd1;
				next_state <= 1'd1;
			end else begin
				tx_ready_t_next_value4 <= 1'd1;
				tx_ready_t_next_value_ce4 <= 1'd1;
				rx_ready_t_next_value5 <= 1'd1;
				rx_ready_t_next_value_ce5 <= 1'd1;
				rx_data_ready_f_next_value0 <= 1'd0;
				rx_data_ready_f_next_value_ce0 <= 1'd1;
				rx_buffer_f_next_value1 <= 1'd0;
				rx_buffer_f_next_value_ce1 <= 1'd1;
				tx_buffer_t_next_value0 <= 1'd0;
				tx_buffer_t_next_value_ce0 <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end

always @(posedge sys_clk) begin
	if ((clk_counter == 1'd0)) begin
		clk_counter <= 2'd3;
	end else begin
		clk_counter <= (clk_counter - 1'd1);
	end
	if (((clk_counter == 1'd0) | (clk_counter == 2'd2))) begin
		sck <= (~sck);
	end
	state <= next_state;
	if (tx_buffer_t_next_value_ce0) begin
		tx_buffer <= tx_buffer_t_next_value0;
	end
	if (ss_latch_t_next_value_ce1) begin
		ss_latch <= ss_latch_t_next_value1;
	end
	if (word_len_latch_t_next_value_ce2) begin
		word_len_latch <= word_len_latch_t_next_value2;
	end
	if (operation_tx_latch_t_next_value_ce3) begin
		operation_tx_latch <= operation_tx_latch_t_next_value3;
	end
	if (tx_ready_t_next_value_ce4) begin
		tx_ready <= tx_ready_t_next_value4;
	end
	if (rx_ready_t_next_value_ce5) begin
		rx_ready <= rx_ready_t_next_value5;
	end
	if (rx_data_ready_f_next_value_ce0) begin
		rx_data_ready <= rx_data_ready_f_next_value0;
	end
	if (rx_buffer_f_next_value_ce1) begin
		rx_buffer <= rx_buffer_f_next_value1;
	end
	if (next_value_ce) begin
		array_muxed = next_value;
		case (ss_latch)
			1'd0: begin
				ss_s <= array_muxed;
			end
			1'd1: begin
				ss_s_1 <= array_muxed;
			end
			2'd2: begin
				ss_s_2 <= array_muxed;
			end
			default: begin
				ss_s_3 <= array_muxed;
			end
		endcase
	end
	if (mosi_t_next_value_ce6) begin
		mosi <= mosi_t_next_value6;
	end
	if (bitno_t_next_value_ce7) begin
		bitno <= bitno_t_next_value7;
	end
	if (sys_rst) begin
		tx_ready <= 1'd1;
		rx_ready <= 1'd1;
		rx_data_ready <= 1'd0;
		sck <= 1'd1;
		mosi <= 1'd0;
		ss_s <= 1'd1;
		ss_s_1 <= 1'd1;
		ss_s_2 <= 1'd1;
		ss_s_3 <= 1'd1;
		clk_counter <= 2'd3;
		bitno <= 4'd0;
		ss_latch <= 2'd0;
		word_len_latch <= 4'd0;
		operation_tx_latch <= 1'd0;
		rx_buffer <= 16'd0;
		tx_buffer <= 16'd0;
		state <= 2'd0;
	end
end

endmodule


