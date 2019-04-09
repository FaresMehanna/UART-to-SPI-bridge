----------------------------------------------------------------------------
--  spi.vhd
--  SPI module
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

entity spi is
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
end spi;

architecture RTL of spi is

    -- constants for frequency and operating frequency conversion
    constant input_HZ : natural := 100000000;
    constant operating_HZ : natural := 10000000;
    constant freq : natural := input_HZ / operating_HZ;
    
    -- counter needed for baud_rate
    signal clk_counter : natural range 0 to freq := freq - 1;
    signal high_strobe : std_logic := '0';
    signal low_strobe : std_logic := '0';
    signal tr_bitno : natural range 0 to 17 := 0;
    signal inner_sck : std_logic := '1';
    signal mask : std_logic := '1';

    -- latch some data
    signal ss_latch : std_logic_vector(1 downto 0);
    signal word_len_latch : std_logic_vector(3 downto 0);
    signal operation_tx_latch : std_logic;
    signal lsb_first_latch : std_logic;
    signal ris_edge_latch : std_logic;
    
    -- to buffer data
    signal tx_buffer : std_logic_vector(15 downto 0) := "0000000000000000";
    signal rx_buffer : std_logic_vector(15 downto 0) := "0000000000000000";
    
    -- fsm for tx opertation
    TYPE fsm_state IS (IDLE, DATA_RX, DATA_TX, STOP, SS, DELAY1, DELAY2);
    Signal state : fsm_state := IDLE;
    
begin

    spi_fsm : process(clk) is
    begin
        if rising_edge(clk) then

            If (reset = '1') then
                tr_bitno <= 0;
                tx_ready <= '1';
                rx_ready <= '1';
                rx_data_ready <= '0';
                ss_1 <= '1';
                ss_2 <= '1';
                ss_3 <= '1';
                ss_4 <= '1';
                state <= IDLE;
                rx_buffer <= "0000000000000000";
                tx_buffer <= "0000000000000000";
                mask <= '1';
            else
                case state is    
                    when IDLE => 
                        If (tx_start = '1' or rx_start = '1') then
                            -- latch inputs
                            tx_buffer <= tx_data;
                            ss_latch <= ss_select;
                            word_len_latch <= word_length;
                            operation_tx_latch <= tx_start;
                            ris_edge_latch <= ris_edge;
                            lsb_first_latch <= lsb_first;
                            -- update status
                            tx_ready <= '0';
                            rx_ready <= '0';
                            --change state
                            state <= SS;
                        end if;
                    
                    when SS =>
                        if ((ris_edge_latch = '1' and high_strobe = '1') or (ris_edge_latch = '0' and low_strobe = '1')) then
                            -- chip select
                            if (ss_latch = "00") then
                                ss_1 <= '0';
                            elsif (ss_latch = "01") then
                                ss_2 <= '0';
                            elsif (ss_latch = "10") then
                                ss_3 <= '0';
                            else
                                ss_4 <= '0';
                            end if;
                            state <= DELAY1;
                        end if;
                        
                        
                    when DELAY1 =>
                        if ((ris_edge_latch = '1' and high_strobe = '1') or (ris_edge_latch = '0' and low_strobe = '1')) then
                            if(operation_tx_latch = '1') then
                                state <= DATA_TX;
                            else
                                mask <= '0';
                                state <= DATA_RX;
                            end if;
                        end if;                    


                    when DATA_TX => 
                        if ((ris_edge_latch = '1' and high_strobe = '1') or (ris_edge_latch = '0' and low_strobe = '1')) then
                            -- data output
                            mask <= '0';
                            if (lsb_first_latch = '1') then
                                mosi <= tx_buffer(tr_bitno);
                            else 
                                mosi <= tx_buffer(15 - tr_bitno);
                            end if;
                            --handle bitno
                            if (tr_bitno = to_integer(unsigned(word_len_latch))) then
                                state <= DELAY2;
                            end if;                            
                            tr_bitno <= tr_bitno + 1;
                        end if;
                        
                    when DELAY2 =>
                        if ((ris_edge_latch = '1' and high_strobe = '1') or (ris_edge_latch = '0' and low_strobe = '1')) then
                                state <= STOP;
                        end if;
                                           
                    when DATA_RX => 
                        if ((ris_edge_latch = '1' and high_strobe = '1') or (ris_edge_latch = '0' and low_strobe = '1')) then
                            -- data input
                            if (lsb_first_latch = '1') then
                                rx_buffer(tr_bitno) <= miso;
                            else 
                                rx_buffer(15 - tr_bitno) <= miso;
                            end if;
                            --handle bitno
                            if (tr_bitno = to_integer(unsigned(word_len_latch))) then
                                rx_data_ready <= '1';
                                state <= STOP;
                            end if;                            
                            tr_bitno <= tr_bitno + 1;
                        end if;
                    
                    
                    when STOP => 
                            -- chip un_select
                            ss_1 <= '1';
                            ss_2 <= '1';
                            ss_3 <= '1';
                            ss_4 <= '1';
                            mask <= '1';
                            tr_bitno <= 0;
                            -- reset data
                            if( operation_tx_latch = '1' or rx_ack = '1') then
                                tx_ready <= '1';
                                rx_ready <= '1';
                                rx_data_ready <= '0';
                                rx_buffer <= "0000000000000000";
                                tx_buffer <= "0000000000000000";
                                state <= IDLE;
                            end if;                       
                end case;            
            end if;
        end if;
    end process spi_fsm;
    
    counters : process(clk) is
    begin
        if rising_edge(clk) then
            If (reset = '1') then
                clk_counter <= freq - 1;
                high_strobe <= '0';
                low_strobe <= '0';
                inner_sck <= '1';
            else
                --handle counter
                if (clk_counter = 0) then
                    clk_counter <= freq - 1;
                else
                    clk_counter <= clk_counter - 1;
                end if;
                -- handle high_strobe & low_strobe
                if (clk_counter = 1) then
                    high_strobe <= '1';
                elsif (clk_counter = (freq / 2) + 1) then
                    low_strobe <= '1';
                else
                    high_strobe <= '0';
                    low_strobe <= '0';
                end if;
                -- handle sck
                if (clk_counter = 1 or clk_counter = (freq / 2) + 1) then
                    inner_sck <= not inner_sck;
                end if;
            end if;
        end if;
    end process counters;
    
    rx_data <= rx_buffer;
    sck <= inner_sck or mask;
    
end RTL;