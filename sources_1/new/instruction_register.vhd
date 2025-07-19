library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_register is
    Port ( CLK     : in  STD_LOGIC;
           Reset   : in  STD_LOGIC;
           IRWrite : in  STD_LOGIC;
           IR_in   : in  STD_LOGIC_VECTOR(15 downto 0);
           IR_out  : out STD_LOGIC_VECTOR(15 downto 0));
end instruction_register;

architecture Behavioral of instruction_register is
    signal IR_reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            IR_reg <= (others => '0');
        elsif rising_edge(CLK) then
            if IRWrite = '1' then
                IR_reg <= IR_in;
            end if;
        end if;
    end process;

    IR_out <= IR_reg;
end Behavioral;