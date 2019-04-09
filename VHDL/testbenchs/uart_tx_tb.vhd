----------------------------------------------------------------------------
--  uart_tx_tb.vhd
--  test bench for UART TX operation
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

entity uart_tx_tb is
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is

    constant c_CLOK_PERIOD : time := 1 sec / 100000000;     -- 100 MHZ
    constant c_UART_CLOK_PERIOD : time := 1 sec / 9600;     -- baud rate
    
    signal r_clk : std_logic := '0';
    signal r_reset : std_logic := '0';
    signal r_tx_port : std_logic := '1';
    signal r_tx_ack : std_logic := '0';
    signal r_tx_data : std_logic_vector (7 downto 0);
    signal r_tx_ready : std_logic;
    
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

    UUT : uart_tx
    port map (
        clk => r_clk,
        reset => r_reset,
        tx_port => r_tx_port,
        tx_ack => r_tx_ack,
        tx_data => r_tx_data,
        tx_ready => r_tx_ready
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

        
        -- data
        r_tx_data <= "10010110";
        r_tx_ack <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_tx_data <= "00000000";
        r_tx_ack <= '0';
        wait for 20*c_UART_CLOK_PERIOD;
        
    end process;
end Behavioral;