library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity id_ex_register is
    Port ( CLK       : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
           Stall     : in  STD_LOGIC; -- Yeni Stall girişi
           RD1_in    : in  STD_LOGIC_VECTOR(31 downto 0);
           RD2_in    : in  STD_LOGIC_VECTOR(31 downto 0);
           ExtImm_in : in  STD_LOGIC_VECTOR(31 downto 0);
           Rd_in     : in  STD_LOGIC_VECTOR(3 downto 0);
           PCSrc_in      : in STD_LOGIC_VECTOR(1 downto 0);
           Branch_in     : in STD_LOGIC;
           RegWrite_in   : in STD_LOGIC;
           ALUSrc_in     : in STD_LOGIC;
           ALUControl_in : in STD_LOGIC_VECTOR(4 downto 0);
           FlagsWrite_in : in STD_LOGIC;
           MemWrite_in   : in STD_LOGIC;
           MemOp_in      : in  STD_LOGIC_VECTOR(1 downto 0);
           SignExt_in    : in  STD_LOGIC;
           MemtoReg_in   : in STD_LOGIC;
           RD1_out    : out STD_LOGIC_VECTOR(31 downto 0);
           RD2_out    : out STD_LOGIC_VECTOR(31 downto 0);
           ExtImm_out : out STD_LOGIC_VECTOR(31 downto 0);
           Rd_out     : out STD_LOGIC_VECTOR(3 downto 0);
           PCSrc_out      : out STD_LOGIC_VECTOR(1 downto 0);
           Branch_out     : out STD_LOGIC;
           RegWrite_out   : out STD_LOGIC;
           ALUSrc_out     : out STD_LOGIC;
           ALUControl_out : out STD_LOGIC_VECTOR(4 downto 0);
           FlagsWrite_out : out STD_LOGIC;
           MemWrite_out   : out STD_LOGIC;
           MemOp_out      : out  STD_LOGIC_VECTOR(1 downto 0);
           SignExt_out    : out  STD_LOGIC;
           MemtoReg_out   : out STD_LOGIC
           );
end id_ex_register;

architecture Behavioral of id_ex_register is
    signal RD1_reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal RD2_reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ExtImm_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Rd_reg     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal PCSrc_reg  : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal Branch_reg     : STD_LOGIC := '0';
    signal RegWrite_reg   : STD_LOGIC := '0';
    signal ALUSrc_reg     : STD_LOGIC := '0';
    signal ALUControl_reg : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal FlagsWrite_reg : STD_LOGIC := '0';
    signal MemWrite_reg   : STD_LOGIC := '0';
    signal MemOp_reg      : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal SignExt_reg    : STD_LOGIC := '0';
    signal MemtoReg_reg   : STD_LOGIC := '0';
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            RD1_reg <= (others => '0');
            RD2_reg <= (others => '0');
            ExtImm_reg <= (others => '0');
            Rd_reg <= (others => '0');
            PCSrc_reg <= (others => '0');
            Branch_reg <= '0';
            RegWrite_reg <= '0';
            ALUSrc_reg <= '0';
            ALUControl_reg <= "00000";
            FlagsWrite_reg <= '0';
            MemWrite_reg <= '0';
            MemOp_reg <= (others => '0');
            SignExt_reg <= '0';
            MemtoReg_reg <= '0';
        elsif rising_edge(CLK) then
            if Stall = '1' then
                -- Stall durumunda kontrol sinyallerini sıfırla (bubble ekle)
                PCSrc_reg <= (others => '0');
                Branch_reg <= '0';
                RegWrite_reg <= '0';
                ALUSrc_reg <= '0';
                ALUControl_reg <= "00000";
                FlagsWrite_reg <= '0';
                MemWrite_reg <= '0';
                MemOp_reg <= (others => '0');
                SignExt_reg <= '0';
                MemtoReg_reg <= '0';
            else
                -- Normal durumda girişleri kaydet
                RD1_reg <= RD1_in;
                RD2_reg <= RD2_in;
                ExtImm_reg <= ExtImm_in;
                Rd_reg <= Rd_in;
                PCSrc_reg <= PCSrc_in;
                Branch_reg <= Branch_in;
                RegWrite_reg <= RegWrite_in;
                ALUSrc_reg <= ALUSrc_in;
                ALUControl_reg <= ALUControl_in;
                FlagsWrite_reg <= FlagsWrite_in;
                MemWrite_reg <= MemWrite_in;
                MemOp_reg <= MemOp_in;
                SignExt_reg <= SignExt_in;
                MemtoReg_reg <= MemtoReg_in;
            end if;
        end if;
    end process;

    RD1_out <= RD1_reg;
    RD2_out <= RD2_reg;
    ExtImm_out <= ExtImm_reg;
    Rd_out <= Rd_reg;
    PCSrc_out <= PCSrc_reg;
    Branch_out <= Branch_reg;
    RegWrite_out <= RegWrite_reg;
    ALUSrc_out <= ALUSrc_reg;
    ALUControl_out <= ALUControl_reg;
    FlagsWrite_out <= FlagsWrite_reg;
    MemWrite_out <= MemWrite_reg;
    MemOp_out <= MemOp_reg;
    SignExt_out <= SignExt_reg;
    MemtoReg_out <= MemtoReg_reg;

end Behavioral;