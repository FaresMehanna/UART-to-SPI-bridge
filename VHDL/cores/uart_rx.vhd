----------------------------------------------------------------------------
--  uart_rx.vhd
--  UART receiver module
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

entity uart_rx is
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
end uart_rx;

architecture RTL of uart_rx is
    -- constants for frequency and baud rate conversion
    constant input_HZ : natural := 100000000;
    constant baud_rate : natural := 9600;
    constant freq : natural := input_HZ / baud_rate;
    
    -- counter needed for baud_rate
    signal rx_counter : natural range 0 to freq := freq - 1;
    signal rx_strobe : std_logic := '0';
    signal rx_bitno : natural range 0 to 8 := 0;
    
    -- fsm for rx opertation
    TYPE fsm_state IS (IDLE, START, DATA, STOP, FULL);
    Signal state : fsm_state := IDLE;
    
begin

    rx_fsm : process(clk) is
    begin
        -- handle normal operation
        if rising_edge(clk) then
            If (reset = '1') then
                state <= IDLE;
                rx_bitno <= 0;
            else
                -- handle rx fsm
                case state is
                    when IDLE => 
                        If (rx_port = '0') then
                            state <= START;
                        end if;
                    
                    when START => 
                        If (rx_strobe = '1') then
                            state <= DATA;
                        end if;
                    
                    when DATA => 
                        If (rx_strobe = '1') then
                            rx_data(rx_bitno) <= rx_port;
                            rx_bitno <= rx_bitno + 1;
                            if (rx_bitno = 7) then
                                state <= STOP;
                            end if;
                        end if;
                    
                    when STOP => 
                        If (rx_strobe = '1' and rx_port = '1') then
                            rx_bitno <= 0;
                            rx_ready <= '1';
                            state <= FULL;
                        end if;
                    
                    when FULL => 
                        If (rx_ack = '1') then
                            rx_ready <= '0';
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
                rx_counter <= freq-1;
                rx_strobe <= '0';
            else
                --handle counter
                if(state = IDLE and rx_port = '0') then
                    rx_counter <= freq / 2;
                else
                    if (rx_counter = 0) then
                        rx_counter <= freq - 1;
                    else
                        rx_counter <= rx_counter - 1;
                    end if;
                end if;
                
                -- handle rx_strobe
                if (rx_counter = 1) then
                    rx_strobe <= '1';
                else
                    rx_strobe <= '0';
                end if;
            end if;
        end if;
    end process counters;

end RTL;