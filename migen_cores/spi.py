'''
----------------------------------------------------------------------------
--  spi.py
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
'''
from migen import *
from migen.genlib.fsm import *
from migen.fhdl import verilog
from utils import _divisor 

class SPI(Module):
	def __init__(self, clk_freq, operating_freq):

		# divisor for need operating_freq.
		divisor = _divisor(freq_in=clk_freq, freq_out=operating_freq, max_ppm=50000)
		assert (divisor%2 == 0)


		''' Inputs '''
		# 0 to 15, as 1 to 16 bits.
		self.word_length = word_length = Signal(4)
		# to select which chip is activated for this I/O.
		self.ss_select = ss_select = Signal(2)
		# start tx operation.
		self.tx_start = tx_start = Signal(reset=0)
		# start rx operation.
		self.rx_start = rx_start = Signal(reset=0)
		# read rx data
		self.rx_ack = rx_ack = Signal(reset=0)
		# tx data to be sent
		self.tx_data = tx_data = Signal(16)


		''' Inputs From slaves '''
		# master input slave output
		self.miso = miso = Signal(1)

		''' Outputs '''
		# received data
		self.rx_data = rx_data = Signal(16)
		# can start tx operation?
		self.tx_ready = tx_ready = Signal(reset=1)
		# can start rx operation?
		self.rx_ready = rx_ready = Signal(reset=1)
		# is rx data is ready to be read?
		self.rx_data_ready = rx_data_ready = Signal(reset=0)
		# lsb first?
		self.lsb_first = lsb_first = Signal(reset=1)
		# operate at rising_edge?
		self.rising_edge = rising_edge = Signal(reset=1)

		''' Outputs To slaves '''
		# shared clk
		self.sck = sck = Signal(1, reset=1)
		# master output slave input
		self.mosi = mosi = Signal(1)
		# chip select - 4 outputs
		self.ss_s = ss_s = Array(Signal(1, reset=1) for _ in range(4));

		''' Inner registers needed '''
		# the timer to create the new clk needed for wanted baud_rate.
		self.clk_counter = clk_counter = Signal(max=divisor, reset=divisor-1)
		# tr_strobe is the signal of the new clk, only 0->1->0 once
		# every "divisor" time.
		self.tr_strobe_high = tr_strobe_high = Signal()
		self.tr_strobe_low = tr_strobe_low = Signal()
		# keep track of the  bits.
		self.bitno = bitno = Signal(4)
		# latch ss
		self.ss_latch = ss_latch = Signal(2)
		# latch word length
		self.word_len_latch = word_len_latch = Signal(4)
		# is it tx or rx operation?
		# 1 is tx, 0 is rx
		self.operation_tx_latch = operation_tx_latch = Signal(1)
		# tx & rx data buffers
		self.rx_buffer = rx_buffer = Signal(16, reset=0)
		self.tx_buffer = tx_buffer = Signal(16, reset=0)


		# I/O
		self.ios = {word_length, ss_select, tx_start, rx_start, rx_ack, tx_data, miso}  |\
			{rx_data, tx_ready, rx_ready, rx_data_ready, sck, mosi, ss_s[0], ss_s[1], ss_s[2], ss_s[3], lsb_first}

		# handle tx_counter & tx_strobe
		self.comb += tr_strobe_high.eq(clk_counter == 0)
		self.comb += tr_strobe_low.eq(clk_counter == int(divisor/2))
		self.sync += \
			If(clk_counter == 0,
				clk_counter.eq(divisor - 1)
			).Else(
				clk_counter.eq(clk_counter - 1)
			)

		# handle sck, the shared clk with the slaves
		self.sync += If((clk_counter == 0) | (clk_counter == (int(divisor/2))),
						sck.eq(~sck),
					)

		#handle rx_data
		self.comb += rx_data.eq(rx_buffer)

		#handle operations
		self.submodules.op_fsm = FSM(reset_state="IDLE")
		self.op_fsm.act("IDLE",
			# status info
			If(tx_start | rx_start,
				# latch inputs
				NextValue(tx_buffer, tx_data),
				NextValue(ss_latch, ss_select),
				NextValue(word_len_latch, word_length),
				NextValue(operation_tx_latch, tx_start),
				# update status
				NextValue(tx_ready, 0),
				NextValue(rx_ready, 0),
				# next state
				NextState("DATA")
			).Else(
				NextValue(tx_ready, 1),
				NextValue(rx_ready, 1),
				NextValue(rx_data_ready, 0),
				NextValue(rx_buffer, 0),
				NextValue(tx_buffer, 0),
			)
		)

		self.op_fsm.act("DATA",
			If((rising_edge & tr_strobe_high) | (~rising_edge & tr_strobe_low),
				# chip select
				NextValue(ss_s[ss_latch], 0),
				# data input
				If(lsb_first,
					NextValue(rx_buffer, Cat(rx_buffer[1:16], miso)),
				).Else(
					NextValue(rx_buffer, Cat(miso, rx_buffer[0:15])),
				),
				# data output
				# data shift
				If(lsb_first,
					NextValue(mosi, tx_buffer[0]),
					NextValue(tx_buffer, Cat(tx_buffer[1:16], 0)),
				).Else(
					NextValue(mosi, tx_buffer[15]),
					NextValue(tx_buffer, Cat(0, tx_buffer[0:15])),
				),
				NextValue(bitno, bitno + 1),
				# move to stop when done
				If(bitno == word_len_latch,
					NextState("STOP"),
					#if rx, then make rx_data_ready = 1
					If(~operation_tx_latch,
						NextValue(rx_data_ready, 1),
					)
				)
			),
		)

		self.op_fsm.act("STOP",
			# chip un-select
			NextValue(ss_s[ss_latch], 1),
			# reset bitno
			NextValue(bitno, 0),
			# if tx then we are done
			If(operation_tx_latch,
					NextState("IDLE"),
			# if rx then we wait until data is read
			).Else(
				If(rx_ack,
					NextState("IDLE"),
					NextValue(rx_data_ready, 0),
				)
			)

		)

if __name__ == "__main__":
	module = SPI(clk_freq=100, operating_freq=25)
	print(verilog.convert(module, module.ios))