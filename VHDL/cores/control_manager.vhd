----------------------------------------------------------------------------
--  control_manager.vhd
--  control unit module for SPI
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

entity control_manager is
    Port (
           clk   : in std_logic;
           reset : in std_logic;
           --
           instruction : in std_logic_vector (7 downto 0);
           valid_input : in std_logic := '0';
           --
           word_length : out std_logic_vector (3 downto 0) := "1111";
           ss_select   : out std_logic_vector (1 downto 0) :=  "00";
           lsb_first   : out std_logic := '1';
           ris_edge    : out std_logic := '1'
        );
end control_manager;

architecture RTL of control_manager is
    signal word_length_store : std_logic_vector (3 downto 0) := "1111";
    signal ss_select_store : std_logic_vector (1 downto 0) :=  "00";       
    signal lsb_first_store : std_logic := '1';      
    signal ris_edge_store : std_logic := '1';      
begin

    cu : process(clk) is
    begin
        if rising_edge(clk) then
            if(reset = '1') then
                word_length_store <= "1111";
                ss_select_store <= "00";
                lsb_first_store <= '1';
                ris_edge_store <= '1';
            else
                if (valid_input = '1' and instruction(7) = '0') then
                    case instruction(6 downto 4) is
                        when "000" =>
                            word_length_store <= instruction(3 downto 0);
                        when "001" =>
                            ss_select_store <= instruction(1 downto 0);
                        when "010" =>
                            lsb_first_store <= instruction(0);
                        when "011" =>
                            ris_edge_store <= instruction(0);
                        when "100" =>
                        when "101" =>
                        when "110" =>
                        when "111" =>
                        when others =>
                    end case;
                end if;
            end if;
        end if;
    end process cu;
    
    word_length <= word_length_store;
    ss_select <= ss_select_store;
    lsb_first <= lsb_first_store;
    ris_edge <= ris_edge_store;
    
end RTL;