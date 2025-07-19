library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity arm_cortex_m0 is
    Port ( Clock   : in  STD_LOGIC;
           Reset : in  STD_LOGIC; 
           -- ALU Çıkışı
           Result_out  : out STD_LOGIC_VECTOR(15 downto 0)
           );
end arm_cortex_m0;

architecture Behavioral of arm_cortex_m0 is
    component clock_divider
        Port (
            clk_in  : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            clk_out : out STD_LOGIC);
    end component;
    
    -- Program Counter Component
    component program_counter
        Port ( CLK     : in  STD_LOGIC;
               Reset   : in  STD_LOGIC;
               PCWrite : in  STD_LOGIC;
               PC_in   : in  STD_LOGIC_VECTOR(31 downto 0);
               PC_out  : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- Instruction Memory Component
    component instruction_memory
        Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
               enable : in  STD_LOGIC;
               RD  : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Adder Component
    component adder
        Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
               B   : in  STD_LOGIC_VECTOR(31 downto 0);
               Sum : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- 3x1 Multiplexer Component
    component mux_3x1
        Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
               B   : in  STD_LOGIC_VECTOR(31 downto 0);
               C   : in  STD_LOGIC_VECTOR(31 downto 0);
               Sel : in  STD_LOGIC_VECTOR(1 downto 0);
               Y   : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- Instruction Register Component
    component instruction_register
        Port ( CLK     : in  STD_LOGIC;
               Reset   : in  STD_LOGIC;
               IRWrite : in  STD_LOGIC;
               IR_in   : in  STD_LOGIC_VECTOR(15 downto 0);
               IR_out  : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Instruction Decoder Component
    component instruction_decoder
        Port ( Instr       : in  STD_LOGIC_VECTOR(15 downto 0);
               StatusFlags : in  STD_LOGIC_VECTOR(3 downto 0);
               A1          : out STD_LOGIC_VECTOR(3 downto 0);
               A2          : out STD_LOGIC_VECTOR(3 downto 0);
               A3          : out STD_LOGIC_VECTOR(3 downto 0);
               PCSrc       : out STD_LOGIC_VECTOR(1 downto 0);
               Branch      : out STD_LOGIC;
               RegSrc      : out STD_LOGIC;
               RegWrite    : out STD_LOGIC;
               ALUSrc      : out STD_LOGIC;
               ALUControl  : out STD_LOGIC_VECTOR(4 downto 0);
               FlagsWrite  : out STD_LOGIC;
               MemWrite    : out STD_LOGIC;
               MemOp       : out STD_LOGIC_VECTOR(1 downto 0);
               SignExt     : out STD_LOGIC;
               MemtoReg    : out STD_LOGIC;
               ImmSrc      : out STD_LOGIC;
               ImmVal      : out STD_LOGIC_VECTOR(10 downto 0));
    end component;
    
    -- 2x1 Multiplexer Component
    component mux_2x1
        Port ( A   : in  STD_LOGIC_VECTOR(31 downto 0);
               B   : in  STD_LOGIC_VECTOR(31 downto 0);
               Sel : in  STD_LOGIC;
               Y   : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- Register File Component
    component register_file
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
               R10  : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- Extender Component
    component extender
        Port ( ImmSrc : in  STD_LOGIC;
               Instr  : in  STD_LOGIC_VECTOR(10 downto 0);
               ExtImm : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    -- ID/EX Register Component
    component id_ex_register
        Port ( CLK       : in  STD_LOGIC;
               Reset     : in  STD_LOGIC;
               Stall     : in  STD_LOGIC;
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
               MemOp_in      : in STD_LOGIC_VECTOR(1 downto 0);
               SignExt_in    : in STD_LOGIC;
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
               MemtoReg_out   : out STD_LOGIC);
    end component;

    -- ALU Component
    component alu
        Port ( A         : in  STD_LOGIC_VECTOR(31 downto 0);
               B         : in  STD_LOGIC_VECTOR(31 downto 0);
               Carry_in  : in  STD_LOGIC;
               ALUControl: in  STD_LOGIC_VECTOR(4 downto 0);
               Result    : out STD_LOGIC_VECTOR(31 downto 0);
               Flags_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    -- Status Register Component
    component status_register
        Port ( CLK       : in  STD_LOGIC;
               Reset     : in  STD_LOGIC;
               FlagsWrite: in  STD_LOGIC;
               Flags_in  : in  STD_LOGIC_VECTOR(3 downto 0);
               Flags_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    -- Data Memory Component
    component data_memory
        Port ( CLK      : in  STD_LOGIC;                    
               MemWrite : in  STD_LOGIC;                    
               MemOp    : in  STD_LOGIC_VECTOR(1 downto 0);
               SignExt  : in  STD_LOGIC;
               A        : in  STD_LOGIC_VECTOR(31 downto 0);
               WD       : in  STD_LOGIC_VECTOR(31 downto 0);
               RD       : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    -- Program Counter Çıkış Sinyali
    signal CLK   : STD_LOGIC := '0';
    -- Program Counter Çıkış Sinyali
    signal pc_out_signal   : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- Instruction Memory Çıkış Sinyali
    signal instr_mem_rd_signal : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    -- Adder Çıkış Sinyali
    signal adder_sum_signal: STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- 3x1 Multiplexer Çıkış Sinyali (PC Source Selection)
    signal mux_pc_y_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- Instruction Register Çıkış Sinyali
    signal ir_out_signal   : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    -- Instruction Decoder Çıkış Sinyalleri
    signal decoder_a1_signal         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal decoder_a2_signal         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal decoder_a3_signal         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal decoder_pcsrc_signal      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decoder_branch_signal     : STD_LOGIC := '0';
    signal decoder_regsrc_signal     : STD_LOGIC := '0';
    signal decoder_regwrite_signal   : STD_LOGIC := '0';
    signal decoder_alusrc_signal     : STD_LOGIC := '0';
    signal decoder_alucontrol_signal : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal decoder_flagswrite_signal : STD_LOGIC := '0';
    signal decoder_memwrite_signal   : STD_LOGIC := '0';
    signal decoder_memop_signal      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decoder_signext_signal    : STD_LOGIC := '0';
    signal decoder_memtoreg_signal   : STD_LOGIC := '0';
    signal decoder_immsrc_signal     : STD_LOGIC := '0';
    signal decoder_immval_signal     : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
    -- 2x1 Multiplexer Çıkış Sinyali
    signal mux_regsrc_y_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal mux_alusrc_y_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal mux_memtoreg_y_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- Register File Çıkış Sinyalleri
    signal reg_file_rd1_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal reg_file_rd2_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal reg_file_r10_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- Extender Çıkış Sinyali
    signal extender_extimm_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- ID/EX Register Çıkış Sinyalleri
    signal id_ex_rd1_out_signal        : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal id_ex_rd2_out_signal        : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal id_ex_extimm_out_signal     : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal id_ex_rd_out_signal         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal id_ex_pcsrc_out_signal      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal id_ex_branch_out_signal     : STD_LOGIC := '0';
    signal id_ex_regwrite_out_signal   : STD_LOGIC := '0';
    signal id_ex_alusrc_out_signal     : STD_LOGIC := '0';
    signal id_ex_alucontrol_out_signal : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal id_ex_flagswrite_out_signal : STD_LOGIC := '0';
    signal id_ex_memwrite_out_signal   : STD_LOGIC := '0';
    signal id_ex_memop_out_signal      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal id_ex_signext_out_signal    : STD_LOGIC := '0';
    signal id_ex_memtoreg_out_signal   : STD_LOGIC := '0';
    -- ALU Çıkış Sinyalleri
    signal alu_result_signal  : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal alu_flags_out_signal : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    -- Status Register Çıkış Sinyali
    signal status_reg_flags_out_signal : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    -- Data Memory Çıkış Sinyali
    signal data_mem_rd_signal : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- Stall Sinyali
    signal stall_signal    : STD_LOGIC := '0';
    signal not_stall_signal   : STD_LOGIC := '0';
    signal not_branch_signal   : STD_LOGIC := '0';
    signal not_decoder_branch_signal   : STD_LOGIC := '0';
    -- Output Sinyali
    signal output : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
begin
    process(reg_file_r10_signal)
        begin
            output <= reg_file_r10_signal(15 downto 0);
    end process;             
    
    process(id_ex_memtoreg_out_signal, id_ex_rd_out_signal, decoder_a1_signal, decoder_a2_signal, stall_signal, not_stall_signal, id_ex_branch_out_signal)
        begin         
            -- Stall Control
            if (id_ex_memtoreg_out_signal = '1' and 
            (id_ex_rd_out_signal = decoder_a1_signal or id_ex_rd_out_signal = decoder_a2_signal) and
             id_ex_rd_out_signal /= "1111") then -- R15 (PC) hariç
                stall_signal <= '1';
            end if;
            not_stall_signal <= not stall_signal;
    end process;
    
    process(decoder_branch_signal, not_branch_signal, id_ex_branch_out_signal)
        begin
            if id_ex_branch_out_signal = '1' then
                not_branch_signal <= id_ex_branch_out_signal;
            elsif decoder_branch_signal = '1' then
                not_branch_signal <= not decoder_branch_signal;
            else
                not_branch_signal <= not decoder_branch_signal;
            end if;
    end process;
    
    process(decoder_branch_signal)
        begin
            not_decoder_branch_signal <= not decoder_branch_signal;
    end process;
    
    ClockDivider: clock_divider
        port map (
            clk_in  => Clock, 
            reset   => Reset,  
            clk_out => CLK
        );  
    
    -- Program Counter Instantiation
    ProgramCounter: program_counter
        port map (
            CLK     => CLK,
            Reset   => Reset,
            PCWrite => not_stall_signal, -- Stall varsa PC yazma durdurulur
            PC_in   => mux_pc_y_signal,
            PC_out  => pc_out_signal
        );
            
    -- Instruction Memory Instantiation
    InstructionMemory: instruction_memory
        port map (
            A   => pc_out_signal,
            enable => not_decoder_branch_signal,
            RD  => instr_mem_rd_signal
        );
    
    -- Adder Instantiation (for PC + 2)
    PCAdder: adder
        port map (
            A   => pc_out_signal,
            B   => X"00000002",
            Sum => adder_sum_signal
        );
    
    -- Instruction Register Instantiation
    InstructionRegister: instruction_register
        port map (
            CLK     => CLK,
            Reset   => Reset,
            IRWrite => not_stall_signal, -- Stall varsa IR yazma durdurulur
            IR_in   => instr_mem_rd_signal,
            IR_out  => ir_out_signal
        ); 
        
    -- Instruction Decoder Instantiation
    InstructionDecoder: instruction_decoder
        port map (
            Instr       => ir_out_signal,
            StatusFlags => alu_flags_out_signal,
            A1          => decoder_a1_signal,
            A2          => decoder_a2_signal,
            A3          => decoder_a3_signal,
            PCSrc       => decoder_pcsrc_signal,
            Branch      => decoder_branch_signal,
            RegSrc      => decoder_regsrc_signal,
            RegWrite    => decoder_regwrite_signal,
            ALUSrc      => decoder_alusrc_signal,
            ALUControl  => decoder_alucontrol_signal,
            FlagsWrite  => decoder_flagswrite_signal,
            MemWrite    => decoder_memwrite_signal,
            MemOp       => decoder_memop_signal,
            SignExt     => decoder_signext_signal,
            MemtoReg    => decoder_memtoreg_signal,
            ImmSrc      => decoder_immsrc_signal,
            ImmVal      => decoder_immval_signal
        );    
        
    -- 2x1 Multiplexer Instantiation (for Register source selection)
    MuxRegSrc: mux_2x1
        port map (
            A   => mux_memtoreg_y_signal,
            B   => adder_sum_signal,
            Sel => decoder_regsrc_signal,
            Y   => mux_regsrc_y_signal
        );   
    
    -- Register File Instantiation
    RegisterFile: register_file
        port map (
            CLK  => CLK,
            Reset=> Reset,
            WE3  => id_ex_regwrite_out_signal,
            A1   => decoder_a1_signal,
            A2   => decoder_a2_signal,
            A3   => id_ex_rd_out_signal,
            WD3  => mux_regsrc_y_signal,
            R15  => adder_sum_signal,
            RD1  => reg_file_rd1_signal,
            RD2  => reg_file_rd2_signal,
            R10  => reg_file_r10_signal
        );   
    
    -- Extender Instantiation
    ExtenderOp: extender
        port map (
            ImmSrc => decoder_immsrc_signal,
            Instr  => decoder_immval_signal,
            ExtImm => extender_extimm_signal
        );  
    
    -- ID/EX Register Instantiation
    IDEXRegisters: id_ex_register
        port map (
            CLK       => CLK,
            Reset     => Reset,
            Stall     => '0',
            RD1_in    => reg_file_rd1_signal,
            RD2_in    => reg_file_rd2_signal,
            ExtImm_in => extender_extimm_signal,
            Rd_in     => decoder_a3_signal,
            PCSrc_in      => decoder_pcsrc_signal,
            Branch_in     => decoder_branch_signal,
            RegWrite_in   => decoder_regwrite_signal,
            ALUSrc_in     => decoder_alusrc_signal,
            ALUControl_in => decoder_alucontrol_signal,
            FlagsWrite_in => decoder_flagswrite_signal,
            MemWrite_in   => decoder_memwrite_signal,
            MemOp_in      => decoder_memop_signal,
            SignExt_in    => decoder_signext_signal,
            MemtoReg_in   => decoder_memtoreg_signal,
            RD1_out    => id_ex_rd1_out_signal,
            RD2_out    => id_ex_rd2_out_signal,
            ExtImm_out => id_ex_extimm_out_signal,
            Rd_out     => id_ex_rd_out_signal,
            PCSrc_out    => id_ex_pcsrc_out_signal,
            Branch_out   => id_ex_branch_out_signal,
            RegWrite_out => id_ex_regwrite_out_signal,
            ALUSrc_out   => id_ex_alusrc_out_signal,
            ALUControl_out => id_ex_alucontrol_out_signal,
            FlagsWrite_out => id_ex_flagswrite_out_signal,
            MemWrite_out   => id_ex_memwrite_out_signal,
            MemOp_out      => id_ex_memop_out_signal,
            SignExt_out    => id_ex_signext_out_signal,
            MemtoReg_out   => id_ex_memtoreg_out_signal
        );   
    
    -- 2x1 Multiplexer Instantiation (for ALU source selection)
    MuxALUSrc: mux_2x1
        port map (
            A   => id_ex_rd2_out_signal,
            B   => id_ex_extimm_out_signal,
            Sel => id_ex_alusrc_out_signal,
            Y   => mux_alusrc_y_signal
        );  
        
    -- ALU Instantiation
    ALUOp: alu
        port map (
            A         => id_ex_rd1_out_signal,
            B         => mux_alusrc_y_signal,
            Carry_in  => status_reg_flags_out_signal(1),
            ALUControl=> id_ex_alucontrol_out_signal,
            Result    => alu_result_signal,
            Flags_out => alu_flags_out_signal
        );   
        
    -- Status Register Instantiation
    StatusRegister: status_register
        port map (
            CLK       => CLK,
            Reset     => Reset,
            FlagsWrite=> id_ex_flagswrite_out_signal,
            Flags_in  => alu_flags_out_signal,
            Flags_out => status_reg_flags_out_signal
        );   
    
    -- Data Memory Instantiation
    DataMemory: data_memory
        port map (
            CLK      => CLK,
            MemWrite => id_ex_memwrite_out_signal,
            MemOp    => id_ex_memop_out_signal,
            SignExt  => id_ex_signext_out_signal,
            A        => alu_result_signal,
            WD       => id_ex_rd2_out_signal,
            RD       => data_mem_rd_signal
        );
           
    -- 2x1 Multiplexer Instantiation (for Mem to Reg selection)
    MuxMemtoReg: mux_2x1
        port map (
            A   => alu_result_signal,
            B   => data_mem_rd_signal,
            Sel => id_ex_memtoreg_out_signal,
            Y   => mux_memtoreg_y_signal
        );
      
    -- 3x1 Multiplexer Instantiation (for PC source selection)
    MuxPCSrc: mux_3x1
        port map (
            A   => adder_sum_signal,
            B   => alu_result_signal,
            C   => mux_memtoreg_y_signal,
            Sel => id_ex_pcsrc_out_signal,
            Y   => mux_pc_y_signal
        );
     
     Result_out <= output;
     
end Behavioral;