----------------------------------------------------------------------------
--  uart_rx_tb.vhd
--  test bench for UART RX operation
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

entity uart_rx_tb is
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is

    constant c_CLOK_PERIOD : time := 1 sec / 100000000;     -- 100 MHZ
    constant c_UART_CLOK_PERIOD : time := 1 sec / 9600;     -- baud rate
    
    signal r_clk : std_logic := '0';
    signal r_reset : std_logic := '0';
    signal r_rx_port : std_logic := '1';
    signal r_rx_ack : std_logic := '0';
    signal r_rx_data : std_logic_vector (7 downto 0);
    signal r_rx_ready : std_logic;
    
    component uart_rx is
        Port (
            clk   : in std_logic;
            reset : in std_logic;
            --
            rx_port : in std_logic;
            rx_ack  : in std_logic;
            --
            rx_data  : out std_logic_vector (7 downto 0);
            rx_ready : out std_logic := '0'
        );
    end component uart_rx;
    
begin

    UUT : uart_rx
    port map (
        clk => r_clk,
        reset => r_reset,
        rx_port => r_rx_port,
        rx_ack => r_rx_ack,
        rx_data => r_rx_data,
        rx_ready => r_rx_ready
    );

    p_clk_generation : process is
    begin
        wait for c_CLOK_PERIOD / 2;
            r_clk <= not r_clk;
    end process;

    
    tb : process is
    begin
        
        -- start bit
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
 
        -- will send 10010110
        -- data bits
        r_rx_port <= '0';
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
        r_rx_port <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        
        -- stop bit
        r_rx_port <= '1';
        wait for c_UART_CLOK_PERIOD;
        
        -- wait a cycle
        wait for c_UART_CLOK_PERIOD;
        
        -- ack the data
        r_rx_ack <= '1';
        wait for c_CLOK_PERIOD;
        r_rx_ack <= '0';
        wait for c_CLOK_PERIOD;        
                
    end process;
end Behavioral;