library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
    Port ( clk_25MHz : in STD_LOGIC;
           y_filt_curr : in UNSIGNED(9 downto 0);
           y_filt_prev : in UNSIGNED(9 downto 0);
           
           current_x : out INTEGER range 0 to 799;
           current_y : out INTEGER range 0 to 524;
           scan_cursor : in INTEGER range 0 to 639;
           
           video_on_out : out BOOLEAN;
           vga_hs    : out STD_LOGIC;
           vga_vs    : out STD_LOGIC;
           vga_r     : out STD_LOGIC_VECTOR(3 downto 0);
           vga_g     : out STD_LOGIC_VECTOR(3 downto 0);
           vga_b     : out STD_LOGIC_VECTOR(3 downto 0));
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    signal h_count : integer range 0 to 799 := 0;
    signal v_count : integer range 0 to 524 := 0;
    signal video_on : boolean;
begin
    
    -- Scan Logic
    process(clk_25MHz)
    begin
        if rising_edge(clk_25MHz) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    vga_hs <= '0' when (h_count >= 656 and h_count < 752) else '1';
    vga_vs <= '0' when (v_count >= 490 and v_count < 492) else '1';
    video_on <= (h_count < 640) and (v_count < 480);
    video_on_out <= video_on;
    current_x <= h_count;
    current_y <= v_count;

    -- Pixel Drawing Logic
    process(video_on, v_count, h_count, y_filt_curr, y_filt_prev, scan_cursor)
        variable is_text_filt : boolean;
        variable y_min, y_max : integer;
        variable is_erased : boolean;
    begin
        vga_r <= (others => '0');
        vga_g <= (others => '0');
        vga_b <= (others => '0');
        
        -- === S?A ??I: THANH QUÉT NH? H?N (10 Pixel) ===
        is_erased := false;
        -- Xóa vùng t? cursor + 1 ??n cursor + 10 (Tr??c ?ây là 40)
        if h_count > scan_cursor and h_count < scan_cursor + 10 then 
            is_erased := true; 
        end if;
        
        -- X? lý Wrap-around (khi g?n cu?i màn hình)
        if scan_cursor < 10 and h_count > (640 - (10 - scan_cursor)) and h_count < 640 then 
            is_erased := true; 
        end if;

        -- Logic v? ch? FILT (Gi? nguyên)
        is_text_filt := false;
        if (h_count >= 10 and h_count <= 12 and v_count >= 10 and v_count <= 25) or 
           (h_count >= 10 and h_count <= 20 and v_count >= 10 and v_count <= 12) or 
           (h_count >= 10 and h_count <= 18 and v_count >= 17 and v_count <= 19) then is_text_filt := true; end if;
        if (h_count >= 25 and h_count <= 27 and v_count >= 10 and v_count <= 25) then is_text_filt := true; end if;
        if (h_count >= 32 and h_count <= 34 and v_count >= 10 and v_count <= 25) or
           (h_count >= 32 and h_count <= 42 and v_count >= 23 and v_count <= 25) then is_text_filt := true; end if;
        if (h_count >= 50 and h_count <= 52 and v_count >= 10 and v_count <= 25) or 
           (h_count >= 45 and h_count <= 57 and v_count >= 10 and v_count <= 12) then is_text_filt := true; end if;

        if video_on then
            if is_erased then
                -- Thanh quét (Scan Bar) t?i ??u kim
                if h_count = scan_cursor then
                   vga_g <= "0100"; -- Xanh m?
                else
                   -- Kho?ng tr?ng sau kim (Xóa s?ch)
                   vga_r <= "0000"; vga_g <= "0000"; vga_b <= "0000";
                end if;
            elsif is_text_filt then
                vga_r <= "1111"; vga_g <= "1111"; vga_b <= "1111"; 
            else
                -- V? L??I (Gi? nguyên)
                if (h_count mod 10 = 0) or (v_count mod 10 = 0) then vga_r <= "0001"; end if;
                if (h_count mod 50 = 0) or (v_count mod 50 = 0) then vga_r <= "0011"; end if;
                if v_count = 240 then vga_r <= "0100"; end if;

                -- V? SÓNG
                if y_filt_curr < y_filt_prev then
                    y_min := to_integer(y_filt_curr); y_max := to_integer(y_filt_prev);
                else
                    y_min := to_integer(y_filt_prev); y_max := to_integer(y_filt_curr);
                end if;
                if (v_count >= y_min - 1) and (v_count <= y_max + 1) then
                    vga_g <= "1111"; vga_r <= "0000"; vga_b <= "0000";
                end if;
            end if;
        else
            vga_r <= "0000"; vga_g <= "0000"; vga_b <= "0000";
        end if;
    end process;

end Behavioral;