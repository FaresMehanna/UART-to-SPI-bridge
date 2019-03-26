from migen import *
from spi import SPI
import random

def spi_tx(dut):
	yield dut.lsb_first.eq(1)
	for i in range(13):
		yield

	# 0b1011001011111101
	yield dut.tx_data.eq(0xb2Fd)
	# 16 bit word
	yield dut.word_length.eq(15)
	yield dut.ss_select.eq(1)
	yield dut.tx_start.eq(1)
	
	yield

	yield dut.tx_data.eq(0)
	yield dut.word_length.eq(0)
	yield dut.ss_select.eq(0)
	yield dut.tx_start.eq(0)

	for i in range(800):
		yield

def spi_rx(dut):
	for i in range(13):
		yield

	#12 bit word
	# 0b000010100100
	num = 0xa4
	yield dut.word_length.eq(11)
	yield dut.ss_select.eq(2)
	yield dut.rx_start.eq(1)
	yield dut.miso.eq(num & 1)	#first bit
	num = num >> 1
	clk = (yield dut.sck)
	yield
	yield dut.ss_select.eq(0)
	yield dut.rx_start.eq(0)
	yield dut.word_length.eq(0)

	trans_bits = 1
	while trans_bits < 12:
		new_clk = (yield dut.sck)
		#rising edge, change data
		if new_clk == 1 and clk == 0 and (yield dut.ss_s[2]) == 0:
			yield dut.miso.eq(num & 1)
			num = num >> 1
			trans_bits += 1
		clk = new_clk
		yield

	while (yield dut.ss_s[2]) == 0:
		yield
	
	yield
	yield dut.rx_ack.eq(1)
	yield
	yield dut.rx_ack.eq(0)
	for i in range(50):
		yield


if __name__ == "__main__":
	dut1 = SPI(clk_freq=100, operating_freq=10)
	run_simulation(dut1, spi_tx(dut1), vcd_name="spi_tx.vcd")
	dut2 = SPI(clk_freq=100, operating_freq=10)
	run_simulation(dut2, spi_rx(dut2), vcd_name="spi_rx.vcd")