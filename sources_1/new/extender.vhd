library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity extender is
    Port ( ImmSrc : in  STD_LOGIC;
           Instr  : in  STD_LOGIC_VECTOR(10 downto 0);
           ExtImm : out STD_LOGIC_VECTOR(31 downto 0)
           );
end extender;

architecture Behavioral of extender is
begin
    ExtImm <= (31 downto 11 => '0') & Instr when ImmSrc = '0' else
              (31 downto 11 => Instr(10)) & Instr;
end Behavioral;