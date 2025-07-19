library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port ( A         : in  STD_LOGIC_VECTOR(31 downto 0);
           B         : in  STD_LOGIC_VECTOR(31 downto 0);
           Carry_in  : in  STD_LOGIC;
           ALUControl: in  STD_LOGIC_VECTOR(4 downto 0);
           Result    : out STD_LOGIC_VECTOR(31 downto 0);
           Flags_out : out STD_LOGIC_VECTOR(3 downto 0)
           );
end alu;

architecture Behavioral of alu is
    signal temp_result : STD_LOGIC_VECTOR(31 downto 0);
    signal sum         : STD_LOGIC_VECTOR(32 downto 0);
    signal N, Z, C, V  : STD_LOGIC;
begin
    process(A, B, Carry_in, ALUControl, sum, temp_result )
        variable shift_amount : integer;
        variable mul_result : signed(63 downto 0);
    begin
        N <= '0'; Z <= '0'; C <= '0'; V <= '0';
        temp_result <= (others => '0');
        sum <= (others => '0');

        case ALUControl is
            -- ADD
            when "00000" =>
                sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B));
                temp_result <= sum(31 downto 0);
                C <= sum(32);
                N <= temp_result(31);
                if (A(31) = B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- ADC
            when "00001" =>
                sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B) + unsigned'("0" & Carry_in));
                temp_result <= sum(31 downto 0);
                C <= sum(32);
                N <= temp_result(31);
                if (A(31) = B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- SUB
            when "00010" =>
                sum <= std_logic_vector(unsigned('0' & A) - unsigned('0' & B));
                temp_result <= sum(31 downto 0);
                C <= not sum(32);
                N <= temp_result(31);
                if (A(31) /= B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- SBC
            when "00011" =>
                sum <= std_logic_vector(unsigned('0' & A) - unsigned('0' & B) - unsigned'("0" & (not Carry_in)));
                temp_result <= sum(31 downto 0);
                C <= not sum(32);
                N <= temp_result(31);
                if (A(31) /= B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- RSB
            when "00100" =>
                sum <= std_logic_vector(unsigned('0' & B) - unsigned('0' & A));
                temp_result <= sum(31 downto 0);
                C <= not sum(32);
                N <= temp_result(31);
                if (B(31) /= A(31) and B(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- MULS
            when "00101" =>
                mul_result := signed(A) * signed(B);
                temp_result <= std_logic_vector(mul_result(31 downto 0));
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- MOV
            when "00110" =>
                temp_result <= B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- MVN
            when "00111" =>
                temp_result <= not B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- AND
            when "01000" =>
                temp_result <= A and B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- ORR
            when "01001" =>
                temp_result <= A or B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- EOR
            when "01010" =>
                temp_result <= A xor B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- BIC
            when "01011" =>
                temp_result <= A and not B;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- LSL
            when "01100" =>
                shift_amount := to_integer(unsigned(B(4 downto 0)));
                if shift_amount >= 0 and shift_amount <= 31 then
                    temp_result <= std_logic_vector(shift_left(unsigned(A), shift_amount));
                    if shift_amount > 0 then
                        C <= A(32 - shift_amount);
                    end if;
                else
                    temp_result <= (others => '0');
                end if;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- LSR
            when "01101" =>
                shift_amount := to_integer(unsigned(B(4 downto 0)));
                if shift_amount >= 0 and shift_amount <= 31 then
                    temp_result <= std_logic_vector(shift_right(unsigned(A), shift_amount));
                    if shift_amount > 0 then
                        C <= A(shift_amount - 1);
                    end if;
                else
                    temp_result <= (others => '0');
                end if;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- ASR
            when "01110" =>
                shift_amount := to_integer(unsigned(B(4 downto 0)));
                if shift_amount >= 0 and shift_amount <= 31 then
                    temp_result <= std_logic_vector(shift_right(signed(A), shift_amount));
                    if shift_amount > 0 then
                        C <= A(shift_amount - 1);
                    end if;
                else
                    temp_result <= (others => A(31));
                    C <= A(31);
                end if;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- ROR
            when "01111" =>
                shift_amount := to_integer(unsigned(B(4 downto 0)));
                if shift_amount > 0 and shift_amount <= 31 then
                    temp_result <= std_logic_vector(rotate_right(unsigned(A), shift_amount));
                    C <= A(shift_amount - 1);
                else
                    temp_result <= A;
                end if;
                N <= temp_result(31);
                if temp_result = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- CMP
            when "10000" =>
                sum <= std_logic_vector(unsigned('0' & A) - unsigned('0' & B));
                temp_result <= A; -- Result unchanged
                C <= not sum(32);
                if (A(31) /= B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                N <= sum(31);
                if sum(31 downto 0) = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- CMN
            when "10001" =>
                sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B));
                temp_result <= A; -- Result unchanged
                C <= sum(32);
                if (A(31) = B(31) and A(31) /= sum(31)) then
                    V <= '1';
                else
                    V <= '0';
                end if;
                N <= sum(31);
                if sum(31 downto 0) = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- TST
            when "10010" =>
                sum <= '0' & std_logic_vector(A and B);
                temp_result <= A; -- Result unchanged
                N <= sum(31);
                if (A and B) = x"00000000" then
                    Z <= '1';
                else
                    Z <= '0';
                end if;

            -- SXTB
            when "10011" =>
                temp_result <= (others => B(7));
                temp_result(7 downto 0) <= B(7 downto 0);

            -- SXTH
            when "10100" =>
                temp_result <= (others => B(15));
                temp_result(15 downto 0) <= B(15 downto 0);

            -- UXTB
            when "10101" =>
                temp_result <= (others => '0');
                temp_result(7 downto 0) <= B(7 downto 0);

            -- UXTH
            when "10110" =>
                temp_result <= (others => '0');
                temp_result(15 downto 0) <= B(15 downto 0);

            -- REV
            when "10111" =>
                temp_result <= B(7 downto 0) & B(15 downto 8) & B(23 downto 16) & B(31 downto 24);

            -- REV16
            when "11000" =>
                temp_result <= B(23 downto 16) & B(31 downto 24) & B(7 downto 0) & B(15 downto 8);

            -- REVSH
            when "11001" =>
                temp_result <= (others => B(7));
                temp_result(15 downto 0) <= B(7 downto 0) & B(15 downto 8);

            -- NOP
            when others =>
                temp_result <= (others => '0');
        end case;
    end process;

    Result <= temp_result;
    Flags_out <= N & Z & C & V;

end Behavioral;