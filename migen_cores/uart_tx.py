from migen import *
from migen.genlib.fsm import *
from migen.fhdl import verilog
from utils import _divisor

class UART_TX(Module):
	def __init__(self, clk_freq, baud_rate):

		# divisor for need baud_rate.
		divisor = _divisor(freq_in=clk_freq, freq_out=baud_rate, max_ppm=50000)

		''' Inputs '''
		# 8-bits input to be transmitted.
		self.tx_data = tx_data = Signal(8)
		# to make the core latch the input and start transmitting it.
		self.tx_ack = tx_ack = Signal()

		''' Outputs '''
		# port to transmit serial data
		self.tx_port = tx_port = Signal(reset=1)
		# is the core ready to transmit new data?
		self.tx_ready = tx_ready = Signal(reset=1)

		# inputs and outputs used to convert to Verilog.
		self.ios = {tx_port, tx_ready} |\
			{tx_data, tx_ack}

		''' Inner registers needed '''
		# the timer to create the new clk needed for wanted baud_rate.
		self.tx_counter = tx_counter = Signal(max=divisor, reset=0)
		# tx_strobe is the signal of the new clk, only 0->1->0 once
		# every "divisor" time.
		self.tx_strobe = tx_strobe = Signal()
		# keep track of transmitting bits.
		self.tx_bitno = tx_bitno = Signal(3, reset=0)
		# to latch the input data.
		self.tx_latch = tx_latch = Signal(8)

		# handle tx_counter & tx_strobe
		self.comb += tx_strobe.eq(tx_counter == 0)
		self.sync += \
			If(tx_counter == 0,
				tx_counter.eq(divisor - 1)
			).Else(
				tx_counter.eq(tx_counter - 1)
			)

		# FSM to handle transmitting the data.
		self.submodules.tx_fsm = FSM(reset_state="IDLE")
		self.tx_fsm.act("IDLE",
			If(self.tx_ack,
				NextValue(tx_counter, divisor - 1),
				NextValue(tx_ready, 0),
				NextValue(tx_latch, self.tx_data),
				NextState("START"),
			).Else(
				NextValue(tx_port, 1),
				NextValue(tx_ready, 1),
			)
		)
		self.tx_fsm.act("START",
			If(self.tx_strobe,
				NextValue(tx_port, 0),
				NextState("DATA"),
			)
		)
		self.tx_fsm.act("DATA",
			If(self.tx_strobe,
				NextValue(tx_port, tx_latch[0]),
				NextValue(tx_latch, Cat(tx_latch[1:8], 0)),
				NextValue(tx_bitno, tx_bitno + 1),
				If(self.tx_bitno == 7,
					NextState("STOP"),
				)
			)
		)
		self.tx_fsm.act("STOP",
			If(self.tx_strobe,
				NextValue(tx_port, 1),
				NextValue(tx_ready, 1),
				NextState("IDLE"),
			)
		)

if __name__ == "__main__":
	module = UART_TX(clk_freq=10**8, baud_rate=9600)
	print(verilog.convert(module, module.ios))