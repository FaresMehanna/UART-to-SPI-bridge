# UART To SPI Bridge Core
This is implementation of UART To SPI core in Migen and in VHDL and there is an auto generated code in Verilog.

## Implementation Details
- The SPI master have four slave ports.
- The SPI and UART works with different clock rates.
- It support generic slave with word size from 1 bit to 16 bits.
- It support burst of data up to 63 words.
- SPI support least significant bit first or most significant bit first.
- SPI support clock polarity (rising edge or filing edge).
- Most functions can be expanded and new functions can be added by using more OP code in the protocol.

## How It Works
You start by sending configuration packets to the unit, by this you choose the slave port, lsb or msb first, clk polarity and word length.
Then you start either a receiving or transmitting transaction specifying the wanted number of words from 0 to 63.

## Protocol Used
| Packet | Function |
| ---- | ---- |
|0 X  X  X  X  X  X  X | Control packet to modify option. |
|1 X  X  X  X  X  X  X  | Transaction packet to initiate a send/recv transaction. |
|0 O1 O2 O3 V1 V2 V3 V4 | Control packet with [O1->O3] being the OP code and [V1->V4] being the value. |
|1 M W1 W2 W3 W4 W5 W6 | Transaction packet with [M] being the mode [M=0, send][M=1, recv] and [W1->W6] being number of words in this transaction. |

| OP Code | Function | Valid Values |
| ---- | ---- | ---- |
| 0b000 | word length | 0 -> 15 representing values of 1 -> 16 |
| 0b001 | slave select | 0 -> 3 |
| 0b010 | lsb first = 1 | 0 -> 1 |
| 0b011 | rising edge =1 | 0 -> 1 |