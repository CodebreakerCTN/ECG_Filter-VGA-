library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Moving_Average_Filter is
    Port ( clk : in STD_LOGIC;
           data_in : in UNSIGNED(9 downto 0);
           data_out : out UNSIGNED(9 downto 0));
end Moving_Average_Filter;

architecture Behavioral of Moving_Average_Filter is
    -- M?ng l?u tr? 8 m?u g?n nh?t
    type delay_line_type is array (0 to 7) of unsigned(11 downto 0);
    signal delay_line : delay_line_type := (others => (others => '0'));
    signal sum : unsigned(14 downto 0) := (others => '0');
begin
    process(clk)
        variable temp_sum : unsigned(14 downto 0);
    begin
        if rising_edge(clk) then
            -- D?ch d? li?u vào hàng ??i
            delay_line(0) <= resize(data_in, 12);
            for i in 1 to 7 loop
                delay_line(i) <= delay_line(i-1);
            end loop;
            
            -- C?ng t?ng 8 m?u
            temp_sum := (others => '0');
            for i in 0 to 7 loop
                temp_sum := temp_sum + delay_line(i);
            end loop;
            sum <= temp_sum;
        end if;
    end process;
    
    -- Chia 8 (D?ch ph?i 3 bit) ?? l?y trung bình
    data_out <= resize(sum(12 downto 3), 10);
end Behavioral;