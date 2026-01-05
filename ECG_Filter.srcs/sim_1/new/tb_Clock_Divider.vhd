----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/22/2025 01:44:02 AM
-- Design Name: 
-- Module Name: tb_Clock_Divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_Clock_Divider is
--  Port ( );
end tb_Clock_Divider;

architecture Behavioral of tb_Clock_Divider is

    -- 1. Khai báo Component c?n test (Unit Under Test - UUT)
    component Clock_Divider
        Port ( clk_in  : in  STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;

    -- 2. Khai báo các tín hi?u ?? n?i vào UUT
    signal clk_100mhz : STD_LOGIC := '0'; -- Tín hi?u gi? l?p xung 100MHz
    signal clk_25mhz  : STD_LOGIC;        -- Tín hi?u ??u ra ?? quan sát

    -- Khai báo chu k? xung nh?p (Clock Period)
    -- 100MHz t??ng ?ng v?i chu k? 10ns
    constant clk_period : time := 10 ns;

begin

    -- 3. Ánh x? (Map) các tín hi?u vào c?ng c?a module chính
    uut: Clock_Divider PORT MAP (
          clk_in => clk_100mhz,
          clk_out => clk_25mhz
        );

    -- 4. Process t?o xung nh?p 100MHz (Stimulus Process)
    clk_process :process
    begin
        clk_100mhz <= '0';
        wait for clk_period/2;  -- Ch? 5ns
        clk_100mhz <= '1';
        wait for clk_period/2;  -- Ch? 5ns
        -- T?ng c?ng 1 chu k? là 10ns -> T?n s? = 1/10ns = 100MHz
    end process;

    -- 5. Process ki?m th? (Simulation Process)
    stim_proc: process
    begin		
        -- Gi? mô ph?ng ch?y trong m?t kho?ng th?i gian ?? quan sát
        wait for 200 ns; 
        
        -- ? ?ây b?n có th? thêm các câu l?nh assert ?? t? ??ng ki?m tra n?u mu?n
        -- Nh?ng v?i bài này, ta ch? c?n nhìn d?ng sóng (Waveform) là ??.
        
        wait; -- D?ng process này l?i mãi mãi
    end process;

end Behavioral;
