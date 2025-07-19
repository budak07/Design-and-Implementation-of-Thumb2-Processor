library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decoder is
    Port ( Instr       : in  STD_LOGIC_VECTOR(15 downto 0);
           StatusFlags : in  STD_LOGIC_VECTOR(3 downto 0); 
           A1          : out STD_LOGIC_VECTOR(3 downto 0); -- <Rn> The register that contains the first operand.
           A2          : out STD_LOGIC_VECTOR(3 downto 0); -- <Rm> The register that is optionally shifted and used as the second operand.
           A3          : out STD_LOGIC_VECTOR(3 downto 0); -- <Rd> The destination register. If <Rd> is omitted, this register is the same as <Rn>.
           PCSrc       : out STD_LOGIC_VECTOR(1 downto 0);
           Branch      : out STD_LOGIC;
           RegSrc      : out STD_LOGIC;
           RegWrite    : out STD_LOGIC;
           ALUSrc      : out STD_LOGIC;
           ALUControl  : out STD_LOGIC_VECTOR(4 downto 0);
           FlagsWrite  : out STD_LOGIC;
           MemWrite    : out STD_LOGIC;
           MemOp       : out  STD_LOGIC_VECTOR(1 downto 0);
           SignExt     : out  STD_LOGIC;                    
           MemtoReg    : out STD_LOGIC;
           ImmSrc      : out STD_LOGIC;
           ImmVal      : out STD_LOGIC_VECTOR(10 downto 0)       
           );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
    -- Condition codes
    constant EQ : STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- Z set
    constant NE : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- Z clear
    constant CS : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- C set
    constant CC : STD_LOGIC_VECTOR(3 downto 0) := "0011"; -- C clear
    constant MI : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- N set
    constant PL : STD_LOGIC_VECTOR(3 downto 0) := "0101"; -- N clear
    constant VS : STD_LOGIC_VECTOR(3 downto 0) := "0110"; -- V set
    constant VC : STD_LOGIC_VECTOR(3 downto 0) := "0111"; -- V clear
    constant HI : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- C set and Z clear
    constant LS : STD_LOGIC_VECTOR(3 downto 0) := "1001"; -- C clear or Z set
    constant GE : STD_LOGIC_VECTOR(3 downto 0) := "1010"; -- N == V
    constant LT : STD_LOGIC_VECTOR(3 downto 0) := "1011"; -- N != V
    constant GT : STD_LOGIC_VECTOR(3 downto 0) := "1100"; -- Z == 0 and N == V
    constant LE : STD_LOGIC_VECTOR(3 downto 0) := "1101"; -- Z == 1 or N != V
    constant UN : STD_LOGIC_VECTOR(3 downto 0) := "1110"; -- UNDEFINED
    constant UP : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- UNPREDICTABLE

    function ConditionPassed(cond : STD_LOGIC_VECTOR(3 downto 0); flags : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC is
        variable N, Z, C, V : STD_LOGIC;
    begin
        N := flags(3); -- Negative
        Z := flags(2); -- Zero
        C := flags(1); -- Carry
        V := flags(0); -- Overflow
        
        case cond is
            when EQ => return Z; -- Z set
            when NE => return not Z; -- Z clear
            when CS => return C; -- C set
            when CC => return not C; -- C clear
            when MI => return N; -- N set
            when PL => return not N; -- N clear
            when VS => return V; -- V set
            when VC => return not V; -- V clear
            when HI => return C and not Z; -- C set and Z clear
            when LS => return not C or Z; -- C clear or Z set
            when GE => return N xnor V; -- N == V
            when LT => return N xor V; -- N != V
            when GT => return not Z and (N xnor V); -- Z == 0 and N == V
            when LE => return Z or (N xor V); -- Z == 1 or N != V
            when UN => return '0'; -- UNDEFINED, treat as not passed
            when UP => return '0'; -- UNPREDICTABLE, treat as not passed
            when others => return '0';
        end case;
    end function;  

begin      
    process(Instr, StatusFlags)
    begin
        A1 <= "0000"; -- Rn
        A2 <= "0000"; -- Rm
        A3 <= "0000"; -- Rd
        PCSrc <= "00"; 
        Branch <= '0';
        RegSrc <= '0'; 
        RegWrite <= '0';
        ALUSrc <= '0'; 
        ALUControl <= "11111";
        FlagsWrite <= '0';
        MemWrite <= '0';
        MemOp <= "00";  
        SignExt <= '0';
        MemtoReg <= '0';
        ImmSrc <= '0'; -- 0: Zero extend, 1: Sign extend
        ImmVal <= (others => '0'); -- imm11/imm8/imm5/imm3
                    
            if Instr(15 downto 6) = "0100000101" then -- ADC Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00001";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                
            elsif Instr(15 downto 9) = "0001110" then -- ADD Immediate (T1)
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "00000000" & Instr(8 downto 6);    
            
            elsif Instr(15 downto 11) = "00110" then -- ADD Immediate (T2)
                A1 <= '0' & Instr(10 downto 8); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 9) = "0001100" then -- ADD Register (T1)
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 8) = "01000100" then -- ADD Register (T2)
                A1 <= Instr(7) & Instr(2 downto 0); -- Rn
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= Instr(7) & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "10101" then -- ADD (SP plus immediate) (T1)
                A1 <= "1101"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 7) = "101100000" then -- ADD (SP plus immediate) (T2)
                A1 <= "1101"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= "1101"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "0000" & Instr(6 downto 0);
            
            elsif Instr(15 downto 8) = "01000100" then -- ADD (SP plus register) (T1)
                A1 <= "1101"; -- Rn
                A2 <= Instr(7) & Instr(2 downto 0); -- Rm
                A3 <= Instr(7) & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 7) = "010001001" then -- ADD (SP plus register) (T2)
                A1 <= "1101"; -- Rn
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= "1101"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "10100" then -- ADR
                A1 <= "1111"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 6) = "0100000000" then -- AND Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "00010" then -- ASR Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "01110";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 6) = "0100000100" then -- ASR Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01110";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 12) = "1101" then -- B (T1)
                if Instr(11 downto 8) = UN or Instr(11 downto 8) = UP then
                    -- UNDEFINED or UNPREDICTABLE: Treat as NOP
                    A1 <= "0000";
                    A2 <= "0000";
                    A3 <= "0000";
                    PCSrc <= "00";
                    Branch <= '0';
                    RegSrc <= '0';
                    RegWrite <= '0';
                    ALUSrc <= '0';
                    ALUControl <= "00000"; -- NOP
                    FlagsWrite <= '0';
                    MemWrite <= '0';
                    MemtoReg <= '0';
                    ImmSrc <= '0';
                    ImmVal <= (others => '0');
                else
                    if ConditionPassed(Instr(11 downto 8), StatusFlags) = '1' then
                        A1 <= "1111"; -- Rn = PC
                        A2 <= "0000"; -- Rm
                        A3 <= "0000"; -- Rd
                        PCSrc <= "01"; -- Select ALU result for PC
                        Branch <= '1';
                        RegSrc <= '0';
                        RegWrite <= '0';
                        ALUSrc <= '1'; -- Use immediate
                        ALUControl <= "00000"; -- ADD operation (PC + imm32)
                        FlagsWrite <= '0';
                        MemWrite <= '0';
                        MemtoReg <= '0';
                        ImmSrc <= '1'; -- Sign extend
                        ImmVal <= (10 downto 8 => Instr(7)) & Instr(7 downto 0); -- imm8
                    else
                        -- Condition not passed, treat as NOP
                        A1 <= "0000";
                        A2 <= "0000";
                        A3 <= "0000";
                        PCSrc <= "00";
                        Branch <= '0';
                        RegSrc <= '0';
                        RegWrite <= '0';
                        ALUSrc <= '0';
                        ALUControl <= "00000"; -- NOP
                        FlagsWrite <= '0';
                        MemWrite <= '0';
                        MemtoReg <= '0';
                        ImmSrc <= '0';
                        ImmVal <= (others => '0');
                    end if;
                end if;
            
            elsif Instr(15 downto 11) = "11100" then -- B (T2)
                A1 <= "1111"; -- Rn = PC
                A2 <= "0000"; -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "01"; -- Select ALU result for PC
                Branch <= '1';
                RegSrc <= '0';
                RegWrite <= '0';
                ALUSrc <= '1'; -- Use immediate
                ALUControl <= "00000"; -- ADD operation (PC + imm32)
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '1'; -- Sign extend
                ImmVal <= Instr(10 downto 0); -- imm11
                    
            elsif Instr(15 downto 6) = "0100001110" then -- BIC Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01011";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 7) = "010001111" then -- BLX
                A1 <= "1111"; -- Rn = PC (to compute return address)
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= "1110"; -- Rd = LR (R14)
                PCSrc <= "10"; -- Select register value for PC (direct branch)
                Branch <= '1';
                RegSrc <= '0';
                RegWrite <= '1'; -- Write to LR
                ALUSrc <= '1';
                ALUControl <= "00000"; -- ADD (PC + 2 for return address)
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "00000000010"; -- Immediate = 2 (PC + 2 for Thumb)    
                
            elsif Instr(15 downto 7) = "010001110" then -- BX
                A1 <= "0000"; -- Rn (not used)
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= "0000"; -- Rd (not used)
                PCSrc <= "10"; -- Select register value for PC (direct branch)
                Branch <= '1';
                RegSrc <= '0';
                RegWrite <= '0';
                ALUSrc <= '0';
                ALUControl <= "11111"; -- NOP (ALU not used)
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');          
                
            elsif Instr(15 downto 6) = "0100001011" then -- CMN Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "10001";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "00101" then -- CMP Immediate
                A1 <= '0' & Instr(10 downto 8); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '1'; 
                ALUControl <= "10000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 6) = "0100001010" then -- CMP Register (T1)
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "10000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 8) = "01000101" then -- CMP Register (T2)
                A1 <= Instr(7) & Instr(2 downto 0); -- Rn
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "10000";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100000001" then -- EOR Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "01101" then -- LDR Immediate (T1)
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
                
            
            elsif Instr(15 downto 11) = "10011" then -- LDR Immediate (T2)
                A1 <= "1101"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 11) = "01001" then -- LDR Literal
                A1 <= "1111"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 9) = "0101100" then -- LDR Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "01111" then -- LDRB Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "10";  
                SignExt <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 9) = "0101110" then -- LDRB Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "10";  
                SignExt <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "10001" then -- LDRH Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "01";
                SignExt <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 9) = "0101101" then -- LDRH Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "01";  
                SignExt <= '0';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 9) = "0101011" then -- LDRSB Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "10";  
                SignExt <= '1';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 9) = "0101111" then -- LDRSH Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "01";  
                SignExt <= '1';
                MemtoReg <= '1';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                                                
            elsif Instr(15 downto 11) = "00000" then -- LSL Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "01100";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 6) = "0100000010" then -- LSL Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01100";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "00001" then -- LSR Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "01101";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 6) = "0100000011" then -- LSR Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01101";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "00100" then -- MOV Immediate
                A1 <= "0000"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00110";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 8) = "01000110" then -- MOV Register (T1)
                A1 <= "0000"; -- Rn
                A2 <= Instr(6 downto 3); -- Rm
                A3 <= Instr(7) & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00110";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0000000000" then -- MOV Register (T2)
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00110";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100001101" then -- MUL Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(2 downto 0); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00101";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100001111" then -- MVN Register
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00111";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 0) = "1011111100000000" then -- NOP
                A1 <= "0000"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                Branch <= '0';
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100001100" then -- ORR Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01001";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "1011101000" then -- REV
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "10111";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
             
            elsif Instr(15 downto 6) = "1011101001" then -- REV16
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "11000";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "1011101011" then -- REVSH
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "11001";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100000111" then -- ROR Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "01111";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                
            elsif Instr(15 downto 6) = "0100001001" then -- RSB Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00100";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "00000000000";
            
            elsif Instr(15 downto 6) = "0100000110" then -- SBC Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00011";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "01100" then -- STR Immediate (T1)
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 11) = "10010" then -- STR Immediate (T2)
                A1 <= "1101"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 9) = "0101000" then -- STR Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 11) = "01110" then -- STRB Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemOp <= "10";  
                SignExt <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
                
            elsif Instr(15 downto 9) = "0101010" then -- STRB Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemOp <= "10";  
                SignExt <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                
            elsif Instr(15 downto 11) = "10000" then -- STRH Immediate
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '1'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemOp <= "01";  
                SignExt <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000000" & Instr(10 downto 6);
            
            elsif Instr(15 downto 9) = "0101001" then -- STRH Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "00000";
                FlagsWrite <= '0';
                MemWrite <= '1';
                MemOp <= "01";  
                SignExt <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                                
            elsif Instr(15 downto 9) = "0001111" then -- SUB Immediate (T1)
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "00000000" & Instr(8 downto 6);
            
            elsif Instr(15 downto 11) = "00111" then -- SUB Immediate (T2)
                A1 <= '0' & Instr(10 downto 8); -- Rn
                A2 <= "0000"; -- Rm
                A3 <= '0' & Instr(10 downto 8); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "000" & Instr(7 downto 0);
            
            elsif Instr(15 downto 9) = "0001101" then -- SUB Register
                A1 <= '0' & Instr(5 downto 3); -- Rn
                A2 <= '0' & Instr(8 downto 6); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "00010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 7) = "101100001" then -- SUB (SP minus immediate)
                A1 <= "1101"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= "1101"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '1'; 
                ALUControl <= "00010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= "0000" & Instr(6 downto 0);
            
            elsif Instr(15 downto 6) = "1011001001" then -- SXTB
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "10011";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "1011001000" then -- SXTH
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "10100";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "0100001000" then -- TST Register
                A1 <= '0' & Instr(2 downto 0); -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "10010";
                FlagsWrite <= '1';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "1011001011" then -- UXTB
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "10101";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
            
            elsif Instr(15 downto 6) = "1011001010" then -- UXTH
                A1 <= "0000"; -- Rn
                A2 <= '0' & Instr(5 downto 3); -- Rm
                A3 <= '0' & Instr(2 downto 0); -- Rd
                PCSrc <= "00"; 
                RegSrc <= '0'; 
                RegWrite <= '1';
                ALUSrc <= '0'; 
                ALUControl <= "10110";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0';
                ImmVal <= (others => '0');
                                                                                                                                                                                                
            else 
                A1 <= "0000"; -- Rn
                A2 <= "0000"; -- Rm
                A3 <= "0000"; -- Rd
                PCSrc <= "00"; 
                Branch <= '0';
                RegSrc <= '0'; 
                RegWrite <= '0';
                ALUSrc <= '0'; 
                ALUControl <= "11111";
                FlagsWrite <= '0';
                MemWrite <= '0';
                MemOp <= "00";  
                SignExt <= '0';
                MemtoReg <= '0';
                ImmSrc <= '0'; -- 0: Zero extend, 1: Sign extend
                ImmVal <= (others => '0'); -- imm11/imm8/imm5/imm3
        end if;                     
    end process;
end Behavioral;