----------------------------------------------------------------------------
--  uart.vhd
--  full UART module
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

entity uart is
    Port (
        clk   : in std_logic;
        reset : in std_logic;
        -- tx 
        tx_data  : in std_logic_vector (7 downto 0);
        tx_ack   : in std_logic;
        tx_port  : out std_logic := '1';
        tx_ready : out std_logic := '1';
        -- rx
        rx_port  : in std_logic;
        rx_ack   : in std_logic;
        rx_data  : out std_logic_vector (7 downto 0);
        rx_ready : out std_logic := '0'
    );
end uart;

architecture RTL of uart is

    component uart_rx is
        port (
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
 
    component uart_tx is
        port (
            clk   : in std_logic;
            reset : in std_logic;
            --
            tx_data : in std_logic_vector (7 downto 0);
            tx_ack  : in std_logic;
            --
            tx_port  : out std_logic := '1';
            tx_ready : out std_logic := '1'
        );
    end component uart_tx;
    
begin

    uart_tx_object : uart_tx
    port map (
        clk => clk,
        reset => reset,
        tx_port => tx_port,
        tx_ack => tx_ack,
        tx_data => tx_data,
        tx_ready => tx_ready
    );
    
    uart_rx_object : uart_rx
    port map (
        clk => clk,
        reset => reset,
        rx_port => rx_port,
        rx_ack => rx_ack,
        rx_data => rx_data,
        rx_ready => rx_ready
    );

end RTL;
