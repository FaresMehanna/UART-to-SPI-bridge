----------------------------------------------------------------------------
--  uart_to_spi.vhd
--  UART to spi bridge module
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


entity uart_to_spi is
    Port (
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
end uart_to_spi;

architecture RTL of uart_to_spi is

    component control_manager is
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
    end component control_manager;

    component uart is
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
    end component uart;
    
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
    
    -- buffer needed
    signal uart_buffer : std_logic_vector (7 downto 0);
    signal spi_buffer : std_logic_vector (15 downto 0);
    signal num_words : natural range 0 to 64;
    
    -- wires for uart
    signal uart_buffer_rx : std_logic_vector (7 downto 0);
    signal uart_buffer_tx : std_logic_vector (7 downto 0);
    signal uart_tx_ack : std_logic := '0';
    signal uart_tx_ready : std_logic;
    signal uart_rx_ack : std_logic := '0';
    signal uart_rx_ready : std_logic;
    
    -- wires for control unit
    signal cu_instruction : std_logic_vector (7 downto 0) :=  "11111111";
    signal cu_valid_input : std_logic :=  '0';
    signal cu_word_length : std_logic_vector (3 downto 0);
    signal cu_ss_select : std_logic_vector (1 downto 0);
    signal cu_lsb_first : std_logic;
    signal cu_ris_edge : std_logic;
    
    -- wires for spi
    signal spi_rx_data_ready : std_logic;
    signal spi_rx_ready : std_logic;
    signal spi_tx_ready : std_logic;
    signal spi_rx_data : std_logic_vector (15 downto 0);
    
    signal spi_rx_ack : std_logic := '0';
    signal spi_rx_start : std_logic := '0';
    signal spi_tx_start : std_logic := '0';
    signal spi_tx_data : std_logic_vector (15 downto 0);

    -- fsm for opertation
    TYPE fsm_state IS (IDLE, HANDLE_COMMAND, HANDLE_CONTROL, RECV_1, RECV_2, RECV_3, RECV_4, RECV_5_WAIT, RECV_5, SEND_1, SEND_2, WAIT_SEND_3, SEND_3, SEND_4);
    Signal state : fsm_state := IDLE;

begin
    
    -- uart connections
    uart_object : uart
    port map (
        clk => clk,
        reset => reset,
        tx_port => tx_port,
        tx_ack => uart_tx_ack,
        tx_data => uart_buffer_tx,
        tx_ready => uart_tx_ready,
        rx_port => rx_port,
        rx_ack => uart_rx_ack,
        rx_data => uart_buffer_rx,
        rx_ready => uart_rx_ready
    );
    
    -- control unit
    cu_object : control_manager
    port map (
        clk => clk,
        reset => reset,
        instruction => cu_instruction,
        valid_input => cu_valid_input,
        word_length => cu_word_length,
        ss_select => cu_ss_select,
        lsb_first => cu_lsb_first,
        ris_edge => cu_ris_edge
     );
     
     -- spi
    spi_object : spi
    port map ( 
        clk => clk,
        reset => reset,
        word_length => cu_word_length,
        ss_select => cu_ss_select,
        tx_start => spi_tx_start,
        rx_start => spi_rx_start,
        rx_ack => spi_rx_ack,
        tx_data => spi_tx_data,
        miso => miso,
        lsb_first => cu_lsb_first,
        ris_edge => cu_ris_edge,
        rx_data => spi_rx_data,
        tx_ready => spi_tx_ready,
        rx_ready => spi_rx_ready,
        rx_data_ready => spi_rx_data_ready,
        sck => sck,
        mosi => mosi,
        ss_1 => ss_1,
        ss_2 => ss_2,
        ss_3 => ss_3,
        ss_4 => ss_4
    );
     
    bridge : process(clk) is
    begin
        if rising_edge(clk) then
            If (reset = '1') then
                state <= IDLE;
            else
                case state is
                    when IDLE =>
                        if (uart_rx_ready = '1') then
                            uart_buffer <= uart_buffer_rx;
                            uart_rx_ack <= '1';
                            state <= HANDLE_COMMAND;
                        else
                            spi_tx_start <= '0';
                            spi_rx_start <= '0';
                            spi_rx_ack <= '0';
                            uart_rx_ack <= '0';
                            uart_tx_ack <= '0';
                        end if;
                    
                    when HANDLE_COMMAND =>
                        uart_rx_ack <= '0';
                        if (uart_buffer(7) = '1') then      -- handle if transfer message
                            num_words <= to_integer(unsigned(uart_buffer(5 downto 0)));
                            if(uart_buffer(6) = '1') then   -- receive
                                state <= RECV_1;
                            else                            -- send
                                state <= SEND_1;
                            end if;
                        else
                            cu_instruction <= uart_buffer;  -- handle if control message
                            cu_valid_input <= '1';
                            state <= HANDLE_CONTROL;
                        end if;
                        
                    when HANDLE_CONTROL =>
                        cu_valid_input <= '0';
                        state <= IDLE;
                        
                    when RECV_1 =>
                        uart_tx_ack <= '0';                 --needed from recv_4 and recv_5
                        if(num_words = 0) then              --done?
                            state <= IDLE;
                        else
                            num_words <= num_words - 1;
                            state <= RECV_2;
                        end if;
                        
                    when RECV_2 =>
                        if(spi_rx_ready = '1') then         -- if spi ready?
                            spi_rx_start <= '1';
                            state <= RECV_3;
                        end if;
                        
                    when RECV_3 =>
                        spi_rx_start <= '0';                --reset
                        if(spi_rx_data_ready = '1') then    -- check spi
                            spi_buffer <= spi_rx_data;
                            spi_rx_ack <= '1';
                            state <= RECV_4;
                        end if;
                        
                    when RECV_4 =>
                        spi_rx_ack <= '0';
                        if(uart_tx_ready = '1') then
                            uart_buffer_tx <= spi_buffer(7 downto 0);
                            uart_tx_ack <= '1';
                            if(to_integer(unsigned(cu_word_length)) > 7) then
                                state <= RECV_5_WAIT;
                            else
                                state <= RECV_1;
                            end if;
                        end if;
                        
                    when RECV_5_WAIT =>
                        uart_tx_ack <= '0';
                        state <= RECV_5;
                        
                    when RECV_5 =>
                        if(uart_tx_ready = '1') then
                            uart_buffer_tx <= spi_buffer(15 downto 8);
                            uart_tx_ack <= '1';
                            state <= RECV_1;
                        end if;
                    
                    when SEND_1 =>
                        spi_tx_start <= '0';                -- needed for SEND_4
                        if(num_words = 0) then
                            state <= IDLE;
                        else
                            num_words <= num_words - 1;
                            state <= SEND_2;
                        end if;
                        
                    when SEND_2 =>
                        if(uart_rx_ready = '1') then        --recv from uart
                            spi_buffer(7 downto 0) <= uart_buffer_rx;
                            uart_rx_ack <= '1';
                            if(to_integer(unsigned(cu_word_length)) > 7) then
                                state <= WAIT_SEND_3;
                            else
                                state <= SEND_4;
                            end if;
                        end if;
                    
                    when WAIT_SEND_3 =>
                        uart_rx_ack <= '0';
                        state <= SEND_3;
                        
                    when SEND_3 =>
                        if(uart_rx_ready = '1') then
                            spi_buffer(15 downto 8) <= uart_buffer_rx;
                            uart_rx_ack <= '1';
                            state <= SEND_4;
                        end if;
                        
                    when SEND_4 =>
                        uart_rx_ack <= '0';
                        if(spi_tx_ready = '1') then
                            spi_tx_data <= spi_buffer;
                            spi_tx_start <= '1';
                            state <= SEND_1;
                        end if;
                end case;
            end if;
        end if;
    end process bridge;
        
end RTL;