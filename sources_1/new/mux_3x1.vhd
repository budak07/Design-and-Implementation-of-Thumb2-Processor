library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_3x1 is
    Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
           B   : in  STD_LOGIC_VECTOR(31 downto 0);
           C   : in  STD_LOGIC_VECTOR(31 downto 0);
           Sel : in  STD_LOGIC_VECTOR(1 downto 0);
           Y   : out STD_LOGIC_VECTOR(31 downto 0) 
           );
end mux_3x1;

architecture Behavioral of mux_3x1 is
begin

    process(A, B, C, Sel)
    begin
       case Sel is
           when "00" =>
               Y <= A;
           when "01" =>
               Y <= B;
           when "10" =>
               Y <= C;
           when others =>
               Y <= (others => '0');
        end case;     
    end process;
end Behavioral;