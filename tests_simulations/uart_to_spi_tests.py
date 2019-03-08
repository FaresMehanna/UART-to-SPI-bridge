from migen import *
from uart_to_spi import UART_TO_SPI
import random

def uart_to_spi_tx(dut):
	
	#make rx port = 1
	yield dut.rx_port.eq(1)
	for i in range(13):
		yield

	# word length #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b00001111
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(20):
		yield dut.rx_port.eq(1)
		yield

	# ss select #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b00010010
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(20):
		yield dut.rx_port.eq(1)
		yield

	# start transaction #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b10000010
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(20):
		yield dut.rx_port.eq(1)
		yield

	# do transaction #
	# first 8 bits
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b10010101
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(50):
		yield dut.rx_port.eq(1)
		yield
	# second 8 bits
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b01101010
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(50):
		yield dut.rx_port.eq(1)
		yield

	#dummy cycles to see spi in outputing the data working
	for _ in range(200):
		yield

	# do transaction #
	# first 8 bits
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b11111111
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(50):
		yield dut.rx_port.eq(1)
		yield
	# second 8 bits
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b00000000
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(50):
		yield dut.rx_port.eq(1)
		yield

	#dummy cycles to see spi in outputing the data working
	for _ in range(200):
		yield


def uart_to_spi_rx(dut):
	
	#make rx port = 1
	yield dut.rx_port.eq(1)
	for i in range(13):
		yield

	# word length #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b00001111
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(20):
		yield dut.rx_port.eq(1)
		yield

	# ss select #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b00010011
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(20):
		yield dut.rx_port.eq(1)
		yield

	# start transaction #
	#start bit
	for _ in range(10):
		yield dut.rx_port.eq(0)
		yield
	num = 0b11000001
	for i in range(8):
		for _ in range (10):
			yield dut.rx_port.eq(num&1)
			yield
		num = num >>1
	# stop bit
	for _ in range(10):
		yield dut.rx_port.eq(1)
		yield

	num = 0b0110101010011011
	yield dut.miso.eq(num & 1)	#first bit
	num = num >> 1
	clk = (yield dut.sck)
	yield
	trans_bits = 1
	while trans_bits < 16:
		new_clk = (yield dut.sck)
		#rising edge, change data
		if new_clk == 1 and clk == 0 and (yield dut.ss_s[3]) == 0:
			yield dut.miso.eq(num & 1)
			num = num >> 1
			trans_bits += 1
		clk = new_clk
		yield

	#dummy
	for _ in range(400):
		yield


if __name__ == "__main__":
	dut1 = UART_TO_SPI(clk_freq=100, spi_operating_freq=25, baud_rate=10)
	run_simulation(dut1, uart_to_spi_tx(dut1), vcd_name="uart_to_spi_tx.vcd")
	dut2 = UART_TO_SPI(clk_freq=100, spi_operating_freq=25, baud_rate=10)
	run_simulation(dut2, uart_to_spi_rx(dut2), vcd_name="uart_to_spi_rx.vcd")