library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2x1 is
    Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
           B   : in  STD_LOGIC_VECTOR(31 downto 0);
           Sel : in  STD_LOGIC;                    
           Y   : out STD_LOGIC_VECTOR(31 downto 0) 
           );
end mux_2x1;

architecture Behavioral of mux_2x1 is
begin
    Y <= A when Sel = '0' else B;
end Behavioral;