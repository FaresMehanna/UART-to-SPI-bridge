----------------------------------------------------------------------------
--  spi_tx_tb.vhd
--  test bench for SPI TX operation
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

entity spi_tx_tb is
end spi_tx_tb;

architecture Behavioral of spi_tx_tb is

    constant c_CLOK_PERIOD : time := 1 sec / 100000000;             -- 100 MHZ
    constant c_OPERATING_CLOK_PERIOD : time := 1 sec / 10000000;    -- 10 MHZ
    
    signal r_clk : std_logic := '0';
    signal r_reset : std_logic := '0';
    signal r_word_length : std_logic_vector (3 downto 0);
    signal r_ss_select : std_logic_vector (1 downto 0);
    signal r_tx_start : std_logic := '0';
    signal r_rx_start : std_logic := '0';
    signal r_rx_ack : std_logic := '0';
    signal r_tx_data : std_logic_vector (15 downto 0);
    signal r_miso : std_logic;
    signal r_lsb_first : std_logic := '1';
    signal r_ris_edge : std_logic := '1';
    signal r_rx_data : std_logic_vector (15 downto 0);
    signal r_tx_ready : std_logic := '1';
    signal r_rx_ready : std_logic := '1';
    signal r_rx_data_ready : std_logic := '0';
    signal r_sck : std_logic := '1';
    signal r_mosi : std_logic;
    signal r_ss_1 : std_logic := '1';
    signal r_ss_2 : std_logic := '1';
    signal r_ss_3 : std_logic := '1';
    signal r_ss_4 : std_logic := '1';
    
    component spi is
        Port ( 
           clk   : in std_logic;
           reset : in std_logic;
           --
           word_length : in std_logic_vector (3 downto 0);
           ss_select   : in std_logic_vector (1 downto 0);
           lsb_first   : in std_logic := '1';
           ris_edge    : in std_logic := '1';
           --
           tx_start : in std_logic := '0';
           rx_start : in std_logic := '0';
           rx_ack   : in std_logic := '0';
           tx_data  : in std_logic_vector (15 downto 0);
           --
           miso : in std_logic;
           mosi : out std_logic;
           sck  : out std_logic := '1';
           --
           rx_data  : out std_logic_vector (15 downto 0);
           tx_ready : out std_logic := '1';
           rx_ready : out std_logic := '1';
           rx_data_ready : out std_logic := '0';
           --
           ss_1 : out std_logic := '1';
           ss_2 : out std_logic := '1';
           ss_3 : out std_logic := '1';
           ss_4 : out std_logic := '1'
        );
    end component spi;

    
    
begin

    UUT : spi
    port map (
        clk => r_clk,
        reset => r_reset,
        word_length => r_word_length,
        ss_select => r_ss_select,
        tx_start => r_tx_start,
        rx_start => r_rx_start,
        rx_ack => r_rx_ack,
        tx_data => r_tx_data,
        miso => r_miso,
        lsb_first => r_lsb_first,
        ris_edge => r_ris_edge,
        rx_data => r_rx_data,
        tx_ready => r_tx_ready,
        rx_ready => r_rx_ready,
        rx_data_ready => r_rx_data_ready,
        sck => r_sck,
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
        wait for c_OPERATING_CLOK_PERIOD;
        
        -- data
        r_tx_data <= "1001011010111100";
        r_word_length <= "1011";
        r_tx_start <= '1';
        r_lsb_first <= '0';
        r_ris_edge <= '1';
        r_ss_select <= "00";
        wait for c_OPERATING_CLOK_PERIOD;
        r_tx_data <= "0000000000000000";
        r_tx_start <= '0';
        
        wait for 20*c_OPERATING_CLOK_PERIOD;
        
    end process;
end Behavioral;