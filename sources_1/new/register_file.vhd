library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port ( CLK  : in  STD_LOGIC;
           Reset: in  STD_LOGIC;
           WE3  : in  STD_LOGIC;
           A1   : in  STD_LOGIC_VECTOR(3 downto 0);
           A2   : in  STD_LOGIC_VECTOR(3 downto 0);
           A3   : in  STD_LOGIC_VECTOR(3 downto 0);
           WD3  : in  STD_LOGIC_VECTOR(31 downto 0);
           R15  : in  STD_LOGIC_VECTOR(31 downto 0);
           RD1  : out STD_LOGIC_VECTOR(31 downto 0);
           RD2  : out STD_LOGIC_VECTOR(31 downto 0);
           R10  : out STD_LOGIC_VECTOR(31 downto 0)
           );
end register_file;

architecture Behavioral of register_file is
    type reg_array is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : reg_array := (
        0  => x"00000000", -- R0: 0
        1  => x"00000000", -- R1: 1
        2  => x"00000000", -- R2: 2
        3  => x"00000000", -- R3: 3
        4  => x"00000000", -- R4: 4
        5  => x"00000000", -- R5: 5
        6  => x"00000000", -- R6: 6
        7  => x"00000000", -- R7: 7
        8  => x"00000000", -- R8: 8
        9  => x"00000000", -- R9: 9
        10 => x"00000000", -- R10: 10
        11 => x"00000000", -- R11: 11
        12 => x"00000000", -- R12: 12
        13 => x"00000000", -- R13: 13
        14 => x"00000000", -- R14: 14
        15 => x"00000000"  -- R15: 0 (will be updated by R15 input)
    );
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            registers(15) <= R15;
            if WE3 = '1' then
                if to_integer(unsigned(A3)) /= 15 then
                    registers(to_integer(unsigned(A3))) <= WD3;
                end if;
            end if;
        end if;
    end process;

    RD1 <= registers(to_integer(unsigned(A1)));
    RD2 <= registers(to_integer(unsigned(A2)));
    R10 <= registers(10);
end Behavioral;