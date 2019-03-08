from migen import *
from migen.genlib.fsm import *
from migen.fhdl import verilog
from utils import * 
from uart_rx import UART_RX
from uart_tx import UART_TX

class UART(Module):
	def __init__(self, clk_freq, baud_rate):

		# submodules
		self.submodules.uart_rx = uart_rx = UART_RX(clk_freq, baud_rate)
		self.submodules.uart_tx = uart_tx = UART_TX(clk_freq, baud_rate)

		''' Inputs '''
		# 8-bits input to be transmitted.
		self.tx_data = tx_data = uart_tx.tx_data
		# to make the core latch the input and start transmitting it.
		self.tx_ack = tx_ack = uart_tx.tx_ack
		# this is the port to receive the serialized data.
		self.rx_port = rx_port = uart_rx.rx_port
		# ack the received data.
		self.rx_ack = rx_ack = uart_rx.rx_ack

		''' Outputs '''
		# port to transmit serial data
		self.tx_port = tx_port = uart_tx.tx_port
		# is the core ready to transmit new data?
		self.tx_ready = tx_ready = uart_tx.tx_ready
		# received data, which is output of the module
		self.rx_data = rx_data = uart_rx.rx_data
		# the data in rx is ready
		self.rx_ready = rx_ready = uart_rx.rx_ready

		# inputs and outputs used to convert to Verilog.
		self.ios = {tx_port, tx_ready, rx_data, rx_ready} |\
			{tx_data, tx_ack, rx_port, rx_ack}


if __name__ == "__main__":
	module = UART(clk_freq=10**8, baud_rate=9600)
	print(verilog.convert(module, module.ios))