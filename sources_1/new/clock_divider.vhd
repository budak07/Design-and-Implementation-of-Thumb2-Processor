library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        clk_in  : in  STD_LOGIC;  -- 100 MHz input clock
        reset   : in  STD_LOGIC;  -- Reset signal
        clk_out : out STD_LOGIC   -- 1 Hz output clock
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal cycle_count : integer range 0 to 1 := 0; -- 0 veya 1 döngüsü
    constant HALF_PERIOD : unsigned(31 downto 0) := to_unsigned(25000000 - 1, 32); -- 0.5 saniye
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            cycle_count <= 0;
            clk_out <= '0';
        elsif rising_edge(clk_in) then
            if counter = HALF_PERIOD then
                counter <= (others => '0');
                if cycle_count = 0 then
                    clk_out <= '1';
                    cycle_count <= 1;
                else
                    clk_out <= '0';
                    cycle_count <= 0;
                end if;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end Behavioral;