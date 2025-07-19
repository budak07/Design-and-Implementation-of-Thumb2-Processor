library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity status_register is
    Port ( CLK       : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
           FlagsWrite: in  STD_LOGIC;
           Flags_in  : in  STD_LOGIC_VECTOR(3 downto 0);
           Flags_out : out STD_LOGIC_VECTOR(3 downto 0)
           );
end status_register;

architecture Behavioral of status_register is
    signal SR_reg : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            SR_reg <= (others => '0');
        elsif rising_edge(CLK) then
            if FlagsWrite = '1' then
                SR_reg <= Flags_in;
            end if;
        end if;
    end process;

    Flags_out <= SR_reg;
end Behavioral;