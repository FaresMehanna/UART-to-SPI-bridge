'''
----------------------------------------------------------------------------
--  uart_to_spi.py
--	UART to SPI bridge
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
'''
from migen import *
from migen.genlib.fsm import *
from migen.fhdl import verilog
from utils import _divisor 
from spi import SPI
from uart import UART

# 0 x x x x x x x = control message
# 0 o1 o2 o3 x x x x = [o1 o2 o3] is the op code
# 0 x x x v1 v2 v3 v4 = [v1 v2 v3 v4] is the value

# 1 x x x x x x x = transfer message
# 1 0 x x x x x x = send message
# 1 1 x x x x x x = recv message
# 1 x m0 m1 m2 m3 m4 m5 = [m0 m1 m2 m3 m4 m5] is how many words for this transfer


class ControlManager(Module):
	def __init__(self):

		# Inputs
		self.instruction = instruction = Signal(8)
		self.valid_input = valid_input = Signal(1)

		# Output control signals
		self.word_length = word_length = Signal(4, reset=0)
		self.ss_select = ss_select = Signal(2, reset=0)
		self.lsb_first = lsb_first = Signal(1, reset=1)
		self.rising_edge = rising_edge = Signal(1, reset=1)

		#handle ss_select
		self.ios = {instruction} | \
			{word_length, ss_select, lsb_first, rising_edge}

		#temp data
		self.word_length_store = word_length_store = Signal(4, reset=0)
		self.ss_select_store = ss_select_store = Signal(2, reset=0)
		self.lsb_first_store = lsb_first_store = Signal(1, reset=1)
		self.rising_edge_store = rising_edge_store = Signal(1, reset=1)

		self.comb += word_length.eq(word_length_store)
		self.comb += ss_select.eq(ss_select_store)
		self.comb += rising_edge.eq(rising_edge_store)

		#handle control messages
		self.sync += If(valid_input & ~(instruction[7]),
					Case(instruction[4:7], {
						0 : word_length_store.eq(instruction[0:4]),
						1 : ss_select_store.eq(instruction[0:2]),
						2 : lsb_first.eq(instruction[0]),
						3 : rising_edge.eq(instruction[0]),
					})
				)


class UART_TO_SPI(Module):
	def __init__(self, clk_freq, baud_rate,  spi_operating_freq):

		# submodules
		self.submodules.uart = uart = UART(clk_freq, baud_rate)
		self.submodules.spi = spi = SPI(clk_freq, spi_operating_freq)
		self.submodules.spi_man = spi_man = ControlManager()

		# UART ports
		self.tx_port = tx_port = uart.tx_port
		self.rx_port = rx_port = uart.rx_port

		# SPI ports
		self.sck = sck = spi.sck
		self.miso = miso = spi.miso
		self.mosi = mosi = spi.mosi
		self.ss_s = ss_s = spi.ss_s

		# interconnect submodules
		# SPI manager
		self.comb += spi.word_length.eq(spi_man.word_length)
		self.comb += spi.ss_select.eq(spi_man.ss_select)
		self.comb += spi.lsb_first.eq(spi_man.lsb_first)
		self.comb += spi.rising_edge.eq(spi_man.rising_edge)

		# I/O
		self.ios = {tx_port, rx_port} | \
			{sck, miso, mosi, ss_s[0], ss_s[1], ss_s[2], ss_s[3]}


		#Inner needed data
		self.uart_buffer = uart_buffer = Signal(8)
		self.spi_buffer = spi_buffer = Signal(16)
		self.num_words = num_words = Signal(6)

		# FSM to implementing protocol 
		self.submodules.op_fsm = FSM(reset_state="IDLE")
		#IDLE, we need to receive data from UART to start.
		self.op_fsm.act("IDLE",
					# is there new data
					If(uart.rx_ready,
						# get the new data
						NextValue(uart_buffer, uart.rx_data),
						# ack the new data
						NextValue(uart.rx_ack, 1),
						# handle the command
						NextState("HANDLE_COMMAND"),
					).Else(
						NextValue(spi.tx_start, 0),
						NextValue(spi.rx_start, 0),
						NextValue(spi.rx_ack, 0),
						NextValue(uart.rx_ack, 0),
						NextValue(uart.tx_ack, 0),
					)
				)

		self.op_fsm.act("HANDLE_COMMAND",
					# un-ack any new data
					NextValue(uart.rx_ack, 0),
					# handle if transfer message
					If(uart_buffer[7],
						# how many words in this transfer?
						NextValue(num_words, uart_buffer[0:6]),
						#recv 
						If(uart_buffer[6],
							NextState("RECV_1"),
						#send
						).Else(
							NextState("SEND_1"),
						),
					# handle if control message
					).Else(
						# send it to the control manager
						spi_man.instruction.eq(uart_buffer),
						spi_man.valid_input.eq(1),
						# handle the command
						NextState("HANDLE_CONTROL"),
					)

				)

		self.op_fsm.act("HANDLE_CONTROL",
					# invalidate the input
					spi_man.valid_input.eq(0),
					# return to idle
					NextState("IDLE"),
				)

		self.op_fsm.act("RECV_1",
					# needed from RECV_4 & RECV_5
					NextValue(uart.tx_ack, 0),
					# done?
					If(num_words == 0,
						NextState("IDLE"),
					).Else(
						# decrease num_words
						NextValue(num_words, num_words - 1),
						# keep going
						NextState("RECV_2"),
					)
				)

		self.op_fsm.act("RECV_2",
					# if spi ready 
					If(spi.rx_ready,
						# start rx operation
						NextValue(spi.rx_start, 1),
						# go to next
						NextState("RECV_3"),
					)
				)
		self.op_fsm.act("RECV_3",
					# set rx_start back to zero
					NextValue(spi.rx_start, 0),
					# if spi ready 
					If(spi.rx_data_ready,
						# get data from spi
						NextValue(spi_buffer, spi.rx_data),
						# ack the received data
						NextValue(spi.rx_ack, 1),
						# go to next
						NextState("RECV_4"),
					)
				)
		self.op_fsm.act("RECV_4",
					# set rx_ack back to zero
					NextValue(spi.rx_ack, 0),
					# if uart ready to send data, send data by UART back.
					If(uart.tx_ready,
						# send data to uart input port.
						NextValue(uart.tx_data, spi_buffer[0:8]),
						# start tx
						NextValue(uart.tx_ack, 1),
						If(spi_man.word_length > 7,
							# go to next
							NextState("RECV_5_WAIT"),
						).Else(
							#recv next word
							NextState("RECV_1"),
						)

					)
				)
		self.op_fsm.act("RECV_5_WAIT",
					NextValue(uart.tx_ack, 0),
					NextState("RECV_5"),
				)
		self.op_fsm.act("RECV_5",
					# if uart ready to send data, send data by UART back.
					If(uart.tx_ready,
						# send data to uart input port.
						NextValue(uart.tx_data, spi_buffer[8:16]),
						# start tx
						NextValue(uart.tx_ack, 1),
						#recv next word
						NextState("RECV_1"),
					)
				)


		self.op_fsm.act("SEND_1",
					# needed from SEND_4
					NextValue(spi.tx_start, 0),
					# done?
					If(num_words == 0,
						NextState("IDLE"),
					).Else(
						# decrease num_words
						NextValue(num_words, num_words - 1),
						# keep going
						NextState("SEND_2"),
					)
				)
		self.op_fsm.act("SEND_2",
					# recv from UART
					If(uart.rx_ready,
						NextValue(spi_buffer[0:8], uart.rx_data),
						NextValue(uart.rx_ack, 1),
						If(spi_man.word_length > 7,
							# recv spi[8:16]
							NextState("WAIT_SEND_3"),
						).Else(
							# send via spi
							NextState("SEND_4"),
						)
					)
				)
		self.op_fsm.act("WAIT_SEND_3",
					NextValue(uart.rx_ack, 0),
					NextState("SEND_3"),
				)

		self.op_fsm.act("SEND_3",
					# recv from UART
					If(uart.rx_ready,
						NextValue(spi_buffer[8:16], uart.rx_data),
						NextValue(uart.rx_ack, 1),
						NextState("SEND_4"),
					)
				)
		self.op_fsm.act("SEND_4",
					NextValue(uart.rx_ack, 0),
					If(spi.tx_ready,
						NextValue(spi.tx_data, spi_buffer),
						NextValue(spi.tx_start, 1),
						NextState("SEND_1"),
					)
				)


if __name__ == "__main__":
	module = UART_TO_SPI(clk_freq=100, spi_operating_freq=25, baud_rate=10)
	print(verilog.convert(module, module.ios))

