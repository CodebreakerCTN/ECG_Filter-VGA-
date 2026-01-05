library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ECG_ROM is
    Port ( clk : in STD_LOGIC;
           addr : in INTEGER range 0 to 639;
           data_out : out UNSIGNED(9 downto 0));
end ECG_ROM;

architecture Behavioral of ECG_ROM is
    -- Khai bao mang co 64 phan tu (tu 0 den 63)
    type rom_type is array (0 to 63) of integer; 
    
    -- Du lieu P-Q-R-S-T mo phong (Truc giua ~240)
    -- Quy tac VGA: S? càng nh? càng ? trên cao, s? càng l?n càng ? d??i th?p
    constant ecg_wave : rom_type := (
        -- 1. Sóng P (B?u b?nh, lên nh?): 10 m?u
        240, 238, 236, 234, 232, 232, 234, 236, 238, 240,
        
        -- 2. ?o?n PR (Ngh? ng?n): 4 m?u
        240, 240, 240, 240,
        
        -- 3. Sóng Q (Nhúng xu?ng nh?): 4 m?u
        242, 245, 250, 245,
        
        -- 4. Ph?c b? R (Vút lên r?t cao - ??nh nh?n): 6 m?u
        220, 180, 130, 70, 130, 180,
        
        -- 5. Sóng S (Nhúng xu?ng sâu): 4 m?u
        240, 270, 290, 260,
        
        -- 6. ?o?n ST (H?i ph?c): 4 m?u
        240, 240, 240, 240,
        
        -- 7. Sóng T (B?u b?nh, r?ng h?n P): 12 m?u
        238, 235, 230, 225, 220, 215, 215, 220, 225, 230, 235, 238,
        
        -- 8. ?o?n ngh? (Isoelectric line) - ?ã rút ng?n còn 20 m?u
        240, 240, 240, 240, 240, 240, 240, 240, 240, 240,
        240, 240, 240, 240, 240, 240, 240, 240, 240, 240
    );

begin
    process(clk)
        variable map_idx : integer;
    begin
        if rising_edge(clk) then
            map_idx := addr mod 64; 
            data_out <= to_unsigned(ecg_wave(map_idx), 10);
        end if;
    end process;
end Behavioral;