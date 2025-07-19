library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arm_cortex_m0_tb is
end arm_cortex_m0_tb;

architecture Behavioral of arm_cortex_m0_tb is
    -- Test edilecek modülün sinyallerini tanımla
    component arm_cortex_m0
        Port ( Clock : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               -- ALU Çıkışı
               Result_out  : out STD_LOGIC_VECTOR(15 downto 0)
               );
    end component;

    -- Giriş sinyalleri
    signal Clock : STD_LOGIC := '0';
    signal Reset : STD_LOGIC := '0';

    -- Çıkış sinyalleri
    signal Result_out     : STD_LOGIC_VECTOR(15 downto 0);

    -- Saat periyodu (10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Test edilecek modülü instantiate et
    UUT: arm_cortex_m0
        port map (
            Clock           => Clock,
            Reset           => Reset,
            Result_out      => Result_out
        );

    -- Saat sinyali oluşturma
    CLK_process: process
    begin
        while True loop
            Clock <= '0';
            wait for CLK_PERIOD / 2;
            Clock <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test senaryosu
    Stimulus_process: process
    begin
        -- Reset'i devre dışı bırak
        Reset <= '0';
        wait for 2000 ns; -- 200 saat döngüsü boyunca çalışsın

        -- Simülasyonu bitir
        wait;
    end process;
end Behavioral;