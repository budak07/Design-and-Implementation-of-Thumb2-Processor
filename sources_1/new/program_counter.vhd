library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity program_counter is
    Port ( CLK     : in  STD_LOGIC;
           Reset   : in  STD_LOGIC;
           PCWrite : in  STD_LOGIC;
           PC_in   : in  STD_LOGIC_VECTOR(31 downto 0);
           PC_out  : out STD_LOGIC_VECTOR(31 downto 0));
end program_counter;

architecture Behavioral of program_counter is
    signal PC_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            PC_reg <= (others => '0');
        elsif rising_edge(CLK) then
            if PCWrite = '1' then
                PC_reg <= PC_in;
            end if;
        end if;
    end process;

    PC_out <= PC_reg;
end Behavioral;