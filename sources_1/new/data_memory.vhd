library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port ( CLK      : in  STD_LOGIC;                    
           MemWrite : in  STD_LOGIC;                    
           MemOp    : in  STD_LOGIC_VECTOR(1 downto 0); -- 00: word, 01: halfword, 10: byte
           SignExt  : in  STD_LOGIC;                    -- 1: signed, 0: unsigned
           A        : in  STD_LOGIC_VECTOR(31 downto 0);
           WD       : in  STD_LOGIC_VECTOR(31 downto 0);
           RD       : out STD_LOGIC_VECTOR(31 downto 0) 
           );
end data_memory;

architecture Behavioral of data_memory is
    type ram_type is array (0 to 4095) of STD_LOGIC_VECTOR(7 downto 0);
    signal RAM : ram_type := (others => (others => '0'));
    signal addr : integer;
    signal data : STD_LOGIC_VECTOR(31 downto 0);

begin
    -- Yazma işlemi
    process(CLK)
    begin
        if rising_edge(CLK) then
            if MemWrite = '1' then
                case MemOp is
                    when "00" => -- Word (STR)
                        RAM(to_integer(unsigned(A(31 downto 0))))     <= WD(7 downto 0);
                        RAM(to_integer(unsigned(A(31 downto 0))+1))   <= WD(15 downto 8);
                        RAM(to_integer(unsigned(A(31 downto 0))+2))   <= WD(23 downto 16);
                        RAM(to_integer(unsigned(A(31 downto 0))+3))   <= WD(31 downto 24);
                    when "01" => -- Halfword (STRH)
                        RAM(to_integer(unsigned(A(31 downto 0))))     <= WD(7 downto 0);
                        RAM(to_integer(unsigned(A(31 downto 0))+1))   <= WD(15 downto 8);
                    when "10" => -- Byte (STRB)
                        RAM(to_integer(unsigned(A(31 downto 0))))     <= WD(7 downto 0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- Okuma işlemi
    process(A, RAM, MemOp, SignExt)
    begin
        addr <= to_integer(unsigned(A(31 downto 0)));
        case MemOp is
            when "00" => -- Word (LDR)
                RD <= RAM(addr + 3) & RAM(addr + 2) & RAM(addr + 1) & RAM(addr);
            when "01" => -- Halfword (LDRH/LDRSH)
                RD <= (others => '0');
                RD(15 downto 0) <= RAM(addr + 1) & RAM(addr);
                if SignExt = '1' and RAM(addr + 1)(7) = '1' then
                    RD(31 downto 16) <= (others => '1');
                end if;
            when "10" => -- Byte (LDRB/LDRSB)
                RD <= (others => '0');
                RD(7 downto 0) <= RAM(addr);
                if SignExt = '1' and RAM(addr)(7) = '1' then
                    RD(31 downto 8) <= (others => '1');
                end if;
            when others =>
                RD <= (others => '0');
        end case;
    end process;
end Behavioral;