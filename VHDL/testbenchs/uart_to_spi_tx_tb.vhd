----------------------------------------------------------------------------
--  uart_to_spi_tx_tb.vhd
--  test bench for UART to SPI TX operation
--  Version 1.0
--
--  Copyright (C) 2019 Fares Mehanna
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_to_spi_tx_tb is
end uart_to_spi_tx_tb;

architecture Behavioral of uart_to_spi_tx_tb is

    constant c_CLOK_PERIOD : time := 1 sec / 100000000;     --100MHZ
    constant c_UART_CLOK_PERIOD : time := 1 sec / 9600;     --baud rate
    
    signal r_clk : std_logic := '0';
    signal r_reset : std_logic := '0';
    signal r_tx_port : std_logic;
    signal r_rx_port : std_logic := '1';
    signal r_sck : std_logic;
    signal r_miso : std_logic;
    signal r_mosi : std_logic;
    signal r_ss_1 : std_logic;
    signal r_ss_2 : std_logic;
    signal r_ss_3 : std_logic;
    signal r_ss_4 : std_logic;
    
    component uart_to_spi is
        port (
           clk   : in std_logic;
           reset : in std_logic;
           --
           rx_port : in std_logic;
           tx_port : out std_logic;
           --
           sck  : out std_logic;
           miso : in std_logic;
           mosi : out std_logic;
           --
           ss_1 : out std_logic;
           ss_2 : out std_logic;
           ss_3 : out std_logic;
           ss_4 : out std_logic
        );
    end component uart_to_spi;
    
    
begin

    UUT : uart_to_spi
    port map (
        clk => r_clk,
        reset => r_reset,
        tx_port => r_tx_port,
        rx_port => r_rx_port,
        sck => r_sck,
        miso => r_miso,
        mosi => r_mosi,
        ss_1 => r_ss_1,
        ss_2 => r_ss_2,
        ss_3 => r_ss_3,
        ss_4 => r_ss_4
    );

    p_clk_generation : process is
    begin
        wait for c_CLOK_PERIOD / 2;
            r_clk <= not r_clk;
    end process;

    
    tb : process is
    begin
        
        -- wait for single cycle
        wait for c_UART_CLOK_PERIOD;
        
        -- send word length 0b00001111
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- select slave chip 0b00010000
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- start new transaction 0b10000010
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- first word - first 8 bits - 0b10101011
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- first word - second 8 bits - 0b11110000
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for 20*c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- second word - first 8 bits - 0b11111111
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for c_UART_CLOK_PERIOD;
        -- second word - second 8 bits - 0b00000000
        r_rx_port <= '0';   --start bit
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';   --stop bit
        wait for c_UART_CLOK_PERIOD;

        wait for 20*c_UART_CLOK_PERIOD;
        
    end process;
end Behavioral;