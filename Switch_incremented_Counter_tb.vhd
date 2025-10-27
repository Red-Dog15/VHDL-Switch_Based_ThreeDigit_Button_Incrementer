-- Testbench for ThreeDigitTallyCounter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ThreeDigitTallyCounter_tb is
end entity;

architecture sim of ThreeDigitTallyCounter_tb is

    -- DUT (Device Under Test) signals
    signal clk_tb     : std_logic := '0';
    signal reset_tb   : std_logic := '1';
    signal button_tb  : std_logic := '1';
    signal sw0_tb     : std_logic := '1';
    signal sw1_tb     : std_logic := '1';
    signal sw2_tb     : std_logic := '1';
    signal sseg0_tb, sseg1_tb, sseg2_tb : std_logic_vector(7 downto 0);
    signal led0_tb, led1_tb, led2_tb : std_logic;

    -- Clock period constant
    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz clock

begin

    ------------------------------------------------------------------
    -- Instantiate the Device Under Test (DUT)
    ------------------------------------------------------------------
    uut: entity work.ThreeDigitTallyCounter
        port map (
            clk     => clk_tb,
            reset   => reset_tb,
            button  => button_tb,
            sw0     => sw0_tb,
            sw1     => sw1_tb,
            sw2     => sw2_tb,
            sseg0   => sseg0_tb,
            sseg1   => sseg1_tb,
            sseg2   => sseg2_tb,
            led0    => led0_tb,
            led1    => led1_tb,
            led2    => led2_tb
        );

    ------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    ------------------------------------------------------------------
    -- Stimulus process
    ------------------------------------------------------------------
    stim_proc : process
    begin
        ------------------------------------------------------------------
        -- Reset the DUT
        ------------------------------------------------------------------
        reset_tb <= '0';      -- Active low reset
        wait for 100 ns;
        reset_tb <= '1';

        ------------------------------------------------------------------
        -- Test 1: Single press with SW0 ON
        ------------------------------------------------------------------
        sw0_tb <= '0';        -- enable +1 increment
        sw1_tb <= '1';
        sw2_tb <= '1';
        wait for 100 ns;

        button_tb <= '0';     -- press
        wait for 50 ms;       -- simulate a long press
        button_tb <= '1';     -- release
        wait for 50 ms;

        ------------------------------------------------------------------
        -- Test 2: SW1 ON (+10 increment)
        ------------------------------------------------------------------
        sw0_tb <= '1';
        sw1_tb <= '0';
        wait for 10 ms;
        button_tb <= '0';
        wait for 50 ms;
        button_tb <= '1';
        wait for 50 ms;

        ------------------------------------------------------------------
        -- Test 3: SW2 ON (+100 increment)
        ------------------------------------------------------------------
        sw1_tb <= '1';
        sw2_tb <= '0';
        wait for 10 ms;
        button_tb <= '0';
        wait for 50 ms;
        button_tb <= '1';
        wait for 50 ms;

        ------------------------------------------------------------------
        -- End of simulation
        ------------------------------------------------------------------
        wait for 200 ms;
        assert false report "Simulation complete." severity note;
        wait;
    end process;

end architecture;
