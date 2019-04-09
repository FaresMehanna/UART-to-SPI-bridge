----------------------------------------------------------------------------
--  uart_tx.vhd
--  UART transmitter module
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

entity uart_tx is
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
end uart_tx;

architecture RTL of uart_tx is
    -- constants for frequency and baud rate conversion
    constant input_HZ : natural := 100000000;
    constant baud_rate : natural := 9600;
    constant freq : natural := input_HZ / baud_rate;
    
    -- counter needed for baud_rate
    signal tx_counter : natural range 0 to freq := freq - 1;
    signal tx_strobe : std_logic := '0';
    signal tx_bitno : natural range 0 to 8 := 0;
    
    -- to latch the input
    signal tx_latch : std_logic_vector (7 downto 0);
    
    -- fsm for tx opertation
    TYPE fsm_state IS (IDLE, START, DATA, STOP);
    Signal state : fsm_state := IDLE;
    
begin

    rx_fsm : process(clk) is
    begin 
        -- handle normal operation
        if rising_edge(clk) then
            If (reset = '1') then
                state <= IDLE;
                tx_bitno <= 0;
            else
                -- handle tx fsm
                case state is
                    when IDLE => 
                        If (tx_ack = '1') then
                            tx_ready <= '0';
                            tx_latch <= tx_data;
                            state <= START;
                        end if;
                    
                    when START => 
                        If (tx_strobe = '1') then
                            tx_port <= '0';
                            state <= DATA;
                        end if;
                    
                    when DATA => 
                        If (tx_strobe = '1') then
                            tx_port <= tx_latch(tx_bitno);
                            tx_bitno <= tx_bitno + 1;
                            if (tx_bitno = 7) then
                                state <= STOP;
                            end if;
                        end if;
                    
                    when STOP => 
                        If (tx_strobe = '1') then
                            tx_bitno <= 0;
                            tx_port <= '1';
                            tx_ready <= '1';
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process rx_fsm;

    counters : process(clk) is
    begin
        if rising_edge(clk) then
            If (reset = '1') then
                tx_counter <= freq-1;
                tx_strobe <= '0';
            else
                --handle counter
                if(state = IDLE and tx_ack = '1') then
                    tx_counter <= freq - 1;
                else
                    if (tx_counter = 0) then
                        tx_counter <= freq - 1;
                    else
                        tx_counter <= tx_counter - 1;
                    end if;
                end if;
                -- handle rx_strobe
                if (tx_counter = 1) then
                    tx_strobe <= '1';
                else
                    tx_strobe <= '0';
                end if;
            end if;
        end if;
    end process counters;

end RTL;