'''
----------------------------------------------------------------------------
--  uart_rx.py
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
'''
from migen import *
from migen.genlib.fsm import *
from migen.fhdl import verilog
from utils import _divisor 

class UART_RX(Module):
	def __init__(self, clk_freq, baud_rate):

		# divisor for need baud_rate.
		divisor = _divisor(freq_in=clk_freq, freq_out=baud_rate, max_ppm=50000)

		''' Inputs '''
		# this is the port to receive the serialized data.
		self.rx_port = rx_port = Signal(reset=1)
		# this input declare that we get the output and the
		# UART RX is ready to receive new data.
		self.rx_ack = rx_ack = Signal(reset=0)

		''' Outputs '''
		# received data, which is output of the module
		self.rx_data = rx_data = Signal(8)
		# is there data to output? this is also output 
		self.rx_ready = rx_ready = Signal(reset=0)

		''' Inner registers needed '''
		# the timer to create the new clk needed for wanted baud_rate.
		self.rx_counter = rx_counter = Signal(max=divisor, reset=divisor-1)
		# rx_strobe is the signal of the new clk, only 0->1->0 once
		# every "divisor" time.
		self.rx_strobe = rx_strobe = Signal()
		# keep track of the received bits.
		self.rx_bitno = rx_bitno = Signal(3)

		# inputs and outputs used to convert to Verilog.
		self.ios = {rx_port, rx_ack} |\
			{rx_data, rx_ready}

		# handle rx_strobe, rx_counter.
		self.comb += rx_strobe.eq(rx_counter == 0)
		self.sync += \
			If(rx_counter == 0,
				rx_counter.eq(divisor - 1)
			).Else(
				rx_counter.eq(rx_counter - 1)
			)

		# FSM to handle receiving the data.
		self.submodules.rx_fsm = FSM(reset_state="IDLE")
		self.rx_fsm.act("IDLE",
			If(~rx_port,
				NextValue(rx_counter, divisor // 2),
				NextState("START")
			).Else(
				NextValue(rx_ready, 0),
			)
		)
		self.rx_fsm.act("START",
			If(rx_strobe,
				NextState("DATA")
			)
		)
		self.rx_fsm.act("DATA",
			If(rx_strobe,
				NextValue(self.rx_data, Cat(self.rx_data[1:8], rx_port)),
				NextValue(rx_bitno, rx_bitno + 1),
				If(rx_bitno == 7,
					NextState("STOP")
				)
			)
		)
		self.rx_fsm.act("STOP",
			If(rx_strobe & rx_port,
				NextValue(rx_ready, 1),
				NextState("FULL"),
			)
		)
		self.rx_fsm.act("FULL",
			If(self.rx_ack,
				NextValue(rx_ready, 0),
				NextState("IDLE")
			)
		)


if __name__ == "__main__":
	module = UART_RX(clk_freq=10**8, baud_rate=9600)
	print(verilog.convert(module, module.ios))