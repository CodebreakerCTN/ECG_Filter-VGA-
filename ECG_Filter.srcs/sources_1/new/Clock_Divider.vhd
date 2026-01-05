----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/22/2025 01:23:35 AM
-- Design Name: 
-- Module Name: Clock_Divider - Behavioral
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

entity Clock_Divider is
    Port ( clk_in  : in  STD_LOGIC; -- 100 MHz
           clk_out : out STD_LOGIC); -- 25 MHz
end Clock_Divider;

architecture Behavioral of Clock_Divider is
    signal count : integer range 0 to 1 := 0;
    signal temp_clk : STD_LOGIC := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if count = 1 then -- Dem 0, 1 (chia 2 lan toggle = chia 4 chu ky)
                temp_clk <= not temp_clk;
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    clk_out <= temp_clk;
end Behavioral;
