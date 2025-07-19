library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port ( A      : in  STD_LOGIC_VECTOR(31 downto 0); 
           enable : in  STD_LOGIC;
           RD     : out STD_LOGIC_VECTOR(15 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
    constant ROM_SIZE : integer := 127;
    type rom_type is array (0 to ROM_SIZE) of STD_LOGIC_VECTOR(15 downto 0);
    constant ROM : rom_type := (
        0  => "1011111100000000", -- NOP 
        1  => "0010000000000010", -- MOV R0, #2
        2  => "0010000100000101", -- MOV R1, #5
        3  => "0100011000000010", -- MOV R2, R0
        4  => "0100011000001011", -- MOV R3, R1
        5  => "0001100000001001", -- ADD R1, R1, R0
        6  => "0100001101010011", -- MUL R3, R2, R3
        7  => "0001100010010000", -- ADD R0, R2, R2
        8  => "0100011000011100", -- MOV R4, R3
        9  => "0100011000000110", -- MOV R6, R0
        10 => "0100001101011010", -- MUL R2, R3, R2
        11 => "1110000000000000", -- B
        12 => "0100011010010010", -- MOV R10, R2        
        127 => "1011111100000000",  -- NOP (default, no operation) 
        others => "1011111100000000"  -- NOP (default, no operation)
    );
    
begin
    process(A, enable)
        variable addr : integer;
    begin
        if enable = '1' then
            addr := to_integer(unsigned(A(31 downto 1)));
            RD <= ROM(addr);
        else
            RD <= ROM(ROM_SIZE);
        end if;
    end process;
end Behavioral;