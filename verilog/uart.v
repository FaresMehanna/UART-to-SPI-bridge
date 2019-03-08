/* Machine-generated using Migen */
module top(
	input rx_port,
	input rx_ack,
	output reg [7:0] rx_data,
	output reg rx_ready,
	input [7:0] tx_data,
	input tx_ack,
	output reg tx_port,
	output reg tx_ready,
	input sys_clk,
	input sys_rst
);

reg [13:0] rx_counter = 14'd10415;
wire rx_strobe;
reg [2:0] rx_bitno = 3'd0;
reg [13:0] tx_counter = 14'd0;
wire tx_strobe;
reg [2:0] tx_bitno = 3'd0;
reg [7:0] tx_latch = 8'd0;
reg [2:0] uart_rx_state = 3'd0;
reg [2:0] uart_rx_next_state;
reg [13:0] rx_counter_uart_rx_t_next_value0;
reg rx_counter_uart_rx_t_next_value_ce0;
reg rx_ready_uart_rx_f_next_value;
reg rx_ready_uart_rx_f_next_value_ce;
reg [7:0] rx_data_uart_rx_t_next_value1;
reg rx_data_uart_rx_t_next_value_ce1;
reg [2:0] rx_bitno_uart_rx_t_next_value2;
reg rx_bitno_uart_rx_t_next_value_ce2;
reg [1:0] uart_tx_state = 2'd0;
reg [1:0] uart_tx_next_state;
reg [13:0] tx_counter_uart_tx_t_next_value0;
reg tx_counter_uart_tx_t_next_value_ce0;
reg tx_ready_uart_tx_t_next_value1;
reg tx_ready_uart_tx_t_next_value_ce1;
reg [7:0] tx_latch_uart_tx_t_next_value2;
reg tx_latch_uart_tx_t_next_value_ce2;
reg tx_port_uart_tx_f_next_value;
reg tx_port_uart_tx_f_next_value_ce;
reg [2:0] tx_bitno_uart_tx_t_next_value3;
reg tx_bitno_uart_tx_t_next_value_ce3;


// Adding a dummy event (using a dummy signal 'dummy_s') to get the simulator
// to run the combinatorial process once at the beginning.
// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign rx_strobe = (rx_counter == 1'd0);

// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	uart_rx_next_state <= 3'd0;
	rx_counter_uart_rx_t_next_value0 <= 14'd0;
	rx_counter_uart_rx_t_next_value_ce0 <= 1'd0;
	rx_ready_uart_rx_f_next_value <= 1'd0;
	rx_ready_uart_rx_f_next_value_ce <= 1'd0;
	rx_data_uart_rx_t_next_value1 <= 8'd0;
	rx_data_uart_rx_t_next_value_ce1 <= 1'd0;
	rx_bitno_uart_rx_t_next_value2 <= 3'd0;
	rx_bitno_uart_rx_t_next_value_ce2 <= 1'd0;
	uart_rx_next_state <= uart_rx_state;
	case (uart_rx_state)
		1'd1: begin
			if (rx_strobe) begin
				uart_rx_next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (rx_strobe) begin
				rx_data_uart_rx_t_next_value1 <= {rx_port, rx_data[7:1]};
				rx_data_uart_rx_t_next_value_ce1 <= 1'd1;
				rx_bitno_uart_rx_t_next_value2 <= (rx_bitno + 1'd1);
				rx_bitno_uart_rx_t_next_value_ce2 <= 1'd1;
				if ((rx_bitno == 3'd7)) begin
					uart_rx_next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if ((rx_strobe & rx_port)) begin
				rx_ready_uart_rx_f_next_value <= 1'd1;
				rx_ready_uart_rx_f_next_value_ce <= 1'd1;
				uart_rx_next_state <= 3'd4;
			end
		end
		3'd4: begin
			if (rx_ack) begin
				rx_ready_uart_rx_f_next_value <= 1'd0;
				rx_ready_uart_rx_f_next_value_ce <= 1'd1;
				uart_rx_next_state <= 1'd0;
			end
		end
		default: begin
			if ((~rx_port)) begin
				rx_counter_uart_rx_t_next_value0 <= 13'd5208;
				rx_counter_uart_rx_t_next_value_ce0 <= 1'd1;
				uart_rx_next_state <= 1'd1;
			end else begin
				rx_ready_uart_rx_f_next_value <= 1'd0;
				rx_ready_uart_rx_f_next_value_ce <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end
assign tx_strobe = (tx_counter == 1'd0);

// synthesis translate_off
reg dummy_d_1;
// synthesis translate_on
always @(*) begin
	uart_tx_next_state <= 2'd0;
	tx_counter_uart_tx_t_next_value0 <= 14'd0;
	tx_counter_uart_tx_t_next_value_ce0 <= 1'd0;
	tx_ready_uart_tx_t_next_value1 <= 1'd0;
	tx_ready_uart_tx_t_next_value_ce1 <= 1'd0;
	tx_latch_uart_tx_t_next_value2 <= 8'd0;
	tx_latch_uart_tx_t_next_value_ce2 <= 1'd0;
	tx_port_uart_tx_f_next_value <= 1'd0;
	tx_port_uart_tx_f_next_value_ce <= 1'd0;
	tx_bitno_uart_tx_t_next_value3 <= 3'd0;
	tx_bitno_uart_tx_t_next_value_ce3 <= 1'd0;
	uart_tx_next_state <= uart_tx_state;
	case (uart_tx_state)
		1'd1: begin
			if (tx_strobe) begin
				tx_port_uart_tx_f_next_value <= 1'd0;
				tx_port_uart_tx_f_next_value_ce <= 1'd1;
				uart_tx_next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (tx_strobe) begin
				tx_port_uart_tx_f_next_value <= tx_latch[0];
				tx_port_uart_tx_f_next_value_ce <= 1'd1;
				tx_latch_uart_tx_t_next_value2 <= {1'd0, tx_latch[7:1]};
				tx_latch_uart_tx_t_next_value_ce2 <= 1'd1;
				tx_bitno_uart_tx_t_next_value3 <= (tx_bitno + 1'd1);
				tx_bitno_uart_tx_t_next_value_ce3 <= 1'd1;
				if ((tx_bitno == 3'd7)) begin
					uart_tx_next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if (tx_strobe) begin
				tx_port_uart_tx_f_next_value <= 1'd1;
				tx_port_uart_tx_f_next_value_ce <= 1'd1;
				tx_ready_uart_tx_t_next_value1 <= 1'd1;
				tx_ready_uart_tx_t_next_value_ce1 <= 1'd1;
				uart_tx_next_state <= 1'd0;
			end
		end
		default: begin
			if (tx_ack) begin
				tx_counter_uart_tx_t_next_value0 <= 14'd10415;
				tx_counter_uart_tx_t_next_value_ce0 <= 1'd1;
				tx_ready_uart_tx_t_next_value1 <= 1'd0;
				tx_ready_uart_tx_t_next_value_ce1 <= 1'd1;
				tx_latch_uart_tx_t_next_value2 <= tx_data;
				tx_latch_uart_tx_t_next_value_ce2 <= 1'd1;
				uart_tx_next_state <= 1'd1;
			end else begin
				tx_port_uart_tx_f_next_value <= 1'd1;
				tx_port_uart_tx_f_next_value_ce <= 1'd1;
				tx_ready_uart_tx_t_next_value1 <= 1'd1;
				tx_ready_uart_tx_t_next_value_ce1 <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d_1 <= dummy_s;
// synthesis translate_on
end

always @(posedge sys_clk) begin
	if ((rx_counter == 1'd0)) begin
		rx_counter <= 14'd10415;
	end else begin
		rx_counter <= (rx_counter - 1'd1);
	end
	uart_rx_state <= uart_rx_next_state;
	if (rx_counter_uart_rx_t_next_value_ce0) begin
		rx_counter <= rx_counter_uart_rx_t_next_value0;
	end
	if (rx_ready_uart_rx_f_next_value_ce) begin
		rx_ready <= rx_ready_uart_rx_f_next_value;
	end
	if (rx_data_uart_rx_t_next_value_ce1) begin
		rx_data <= rx_data_uart_rx_t_next_value1;
	end
	if (rx_bitno_uart_rx_t_next_value_ce2) begin
		rx_bitno <= rx_bitno_uart_rx_t_next_value2;
	end
	if ((tx_counter == 1'd0)) begin
		tx_counter <= 14'd10415;
	end else begin
		tx_counter <= (tx_counter - 1'd1);
	end
	uart_tx_state <= uart_tx_next_state;
	if (tx_counter_uart_tx_t_next_value_ce0) begin
		tx_counter <= tx_counter_uart_tx_t_next_value0;
	end
	if (tx_ready_uart_tx_t_next_value_ce1) begin
		tx_ready <= tx_ready_uart_tx_t_next_value1;
	end
	if (tx_latch_uart_tx_t_next_value_ce2) begin
		tx_latch <= tx_latch_uart_tx_t_next_value2;
	end
	if (tx_port_uart_tx_f_next_value_ce) begin
		tx_port <= tx_port_uart_tx_f_next_value;
	end
	if (tx_bitno_uart_tx_t_next_value_ce3) begin
		tx_bitno <= tx_bitno_uart_tx_t_next_value3;
	end
	if (sys_rst) begin
		rx_data <= 8'd0;
		rx_ready <= 1'd0;
		rx_counter <= 14'd10415;
		rx_bitno <= 3'd0;
		tx_port <= 1'd1;
		tx_ready <= 1'd1;
		tx_counter <= 14'd0;
		tx_bitno <= 3'd0;
		tx_latch <= 8'd0;
		uart_rx_state <= 3'd0;
		uart_tx_state <= 2'd0;
	end
end

endmodule


