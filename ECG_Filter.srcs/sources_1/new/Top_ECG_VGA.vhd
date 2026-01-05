library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_ECG_VGA is
    Port ( CLK100MHZ : in STD_LOGIC;
           sw        : in STD_LOGIC_VECTOR(0 downto 0); -- THÊM C?NG SWITCH
           vga_p_r   : out STD_LOGIC_VECTOR(3 downto 0);
           vga_p_g   : out STD_LOGIC_VECTOR(3 downto 0);
           vga_p_b   : out STD_LOGIC_VECTOR(3 downto 0);
           vga_p_hs  : out STD_LOGIC;
           vga_p_vs  : out STD_LOGIC);
end Top_ECG_VGA;

architecture Behavioral of Top_ECG_VGA is
    signal clk_25 : STD_LOGIC;
    
    signal current_x : INTEGER range 0 to 799;
    signal current_y : INTEGER range 0 to 524;
    signal video_active : BOOLEAN;

    signal raw_rom_1, raw_rom_2 : UNSIGNED(9 downto 0);
    
    -- RAM Video
    type MEM_TYPE is array (0 to 639) of integer range 0 to 511;
    signal ram_filt : MEM_TYPE := (others => 360);
    
    signal scan_cursor : INTEGER range 0 to 639 := 0;
    signal frame_counter : INTEGER range 0 to 1000000 := 0;
    signal rom_ptr : INTEGER := 0; 
    
    signal rom_addr_1, rom_addr_2 : INTEGER range 0 to 63;
    
    signal y_filt_curr, y_filt_prev : UNSIGNED(9 downto 0);

    -- Tín hi?u ng?u nhiên (LFSR)
    signal lfsr : UNSIGNED(15 downto 0) := x"ACE1";
    
begin
    
    U1: entity work.Clock_Divider port map (clk_in => CLK100MHZ, clk_out => clk_25);

    -- 1. T?o s? ng?u nhiên (LFSR ch?y liên t?c k? c? khi Pause ?? ??m b?o tính ng?u nhiên)
    process(clk_25)
    begin
        if rising_edge(clk_25) then
            lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
        end if;
    end process;

    -- 2. Tính toán ??a ch? ROM
    rom_addr_1 <= (rom_ptr / 3) mod 64;
    rom_addr_2 <= ((rom_ptr / 3) + 1) mod 64;

    ROM_INST_1: entity work.ECG_ROM port map (clk => clk_25, addr => rom_addr_1, data_out => raw_rom_1);
    ROM_INST_2: entity work.ECG_ROM port map (clk => clk_25, addr => rom_addr_2, data_out => raw_rom_2);
    
    -- 3. Logic C?p nh?t (CÓ CH?C N?NG PAUSE & RANDOM)
    process(clk_25)
        variable diff_filt : signed(10 downto 0);
        variable change_filt : signed(14 downto 0);
        variable base_filt : signed(14 downto 0);
        variable filt_shifted : integer;
        variable step_curr : integer;
        
        -- Bi?n ?? t?o ?? tr? ng?u nhiên (Random Delay)
        variable random_speed_add : integer;
    begin
        if rising_edge(clk_25) then
            
            -- KI?M TRA SWITCH 0: N?u g?t lên (1) thì d?ng c?p nh?t (Freeze)
            if sw(0) = '0' then
            
                -- T?O S? NG?U NHIÊN CHO T?C ??:
                -- L?y 8 bit t? LFSR ?? thay ??i ng??ng ??m
                -- T?c ?? c? b?n: 200,000
                -- C?ng thêm: 0 ??n 50,000 -> Nh?p tim thay ??i ~20%
                random_speed_add := to_integer(lfsr(7 downto 0)) * 200; 

                if frame_counter >= (180000 + random_speed_add) then 
                    frame_counter <= 0;
                    
                    -- Di chuy?n Cursor
                    if scan_cursor = 639 then
                        scan_cursor <= 0;
                    else
                        scan_cursor <= scan_cursor + 1;
                    end if;
                    
                    -- Di chuy?n d? li?u ROM
                    rom_ptr <= rom_ptr + 1; 
                else
                    frame_counter <= frame_counter + 1;
                end if;

                -- TÍNH TOÁN VÀ GHI VÀO RAM
                step_curr := rom_ptr mod 3;
                diff_filt := signed('0' & raw_rom_2) - signed('0' & raw_rom_1);
                change_filt := diff_filt * to_signed(step_curr, 4);
                base_filt := signed(resize(raw_rom_1, 15));
                
                filt_shifted := 240 + (to_integer(base_filt + (change_filt / 3)) - 240) / 2;
                
                if filt_shifted < 10 then filt_shifted := 10; end if;
                if filt_shifted > 470 then filt_shifted := 470; end if;
                
                ram_filt(scan_cursor) <= filt_shifted;
                
            end if; -- End if sw(0) check
        end if;
    end process;

    -- 4. ??c RAM (VGA Read)
    process(clk_25)
        variable val_temp : unsigned(9 downto 0);
    begin
        if rising_edge(clk_25) then
            if current_x >= 0 and current_x <= 639 then
                val_temp := to_unsigned(ram_filt(current_x), 10);
                y_filt_curr <= val_temp;
                if current_x = 0 then
                    y_filt_prev <= val_temp; 
                else
                    y_filt_prev <= y_filt_curr;
                end if;
            else
                y_filt_curr <= (others => '0');
                y_filt_prev <= (others => '0');
            end if;
        end if;
    end process;

    -- 5. VGA Controller
    U4: entity work.VGA_Controller 
        port map (
            clk_25MHz => clk_25,
            y_filt_curr => y_filt_curr,
            y_filt_prev => y_filt_prev,
            current_x => current_x,
            current_y => current_y,
            scan_cursor => scan_cursor,
            video_on_out => video_active,
            vga_hs => vga_p_hs, vga_vs => vga_p_vs,
            vga_r => vga_p_r, vga_g => vga_p_g, vga_b => vga_p_b
        );

end Behavioral;