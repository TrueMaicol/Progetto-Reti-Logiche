library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity serial_to_parallel is port (
    i_clk : in std_logic;
    i_rst: in std_logic;
    i_w : in std_logic;
	o_par : out std_logic_vector(15 downto 0));
end serial_to_parallel;

architecture Behavioral of serial_to_parallel is
    signal temp: std_logic_vector(15 downto 0);
    begin
        process(i_clk, i_rst)
        begin
            if (i_clk'event and i_clk='1') then
                if(i_rst='1') then
                    temp <= "0000000000000000";
                else    
                    temp <= temp(14 downto 0) & i_w;
                end if;
		    end if;
		end process;
	o_par <= temp;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is port ( 
    i_clk : in std_logic; 
    i_rst : in std_logic; 
    i_start : in std_logic; 
    i_w : in std_logic; 
    o_z0 : out std_logic_vector(7 downto 0); 
    o_z1 : out std_logic_vector(7 downto 0); 
    o_z2 : out std_logic_vector(7 downto 0); 
    o_z3 : out std_logic_vector(7 downto 0); 
    o_done : out std_logic; 
    o_mem_addr : out std_logic_vector(15 downto 0); 
    i_mem_data : in std_logic_vector(7 downto 0); 
    o_mem_we : out std_logic; 
    o_mem_en : out std_logic 
); 
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    component serial_to_parallel is port (
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_w : in std_logic;
        o_par : out std_logic_vector(15 downto 0)
    );
    end component;
    component DATAPATH is port ( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        done : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        z0_load : in std_logic;
        z1_load : in std_logic;
        z2_load : in std_logic;
        z3_load : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic
    );
    end component;
    
    type S is (WAIT_START,ADD1,ADD2,LOAD_MEM,SAVE_DATA,OUTPUT);
    signal curr_state : S;
    signal s_w : std_logic;
    signal s_rst : std_logic;
    signal s_addr : std_logic_vector(15 downto 0);
    signal done : std_logic;
    signal z0_load : std_logic;
    signal z1_load : std_logic;
    signal z2_load : std_logic;
    signal z3_load : std_logic;
    signal d_sel : std_logic_vector(1 downto 0);
    signal d0_load : std_logic;
    signal d1_load : std_logic;
    
begin
    SHIFTER : serial_to_parallel port map(
        i_clk => i_clk,
        i_rst => s_rst,
        i_w => i_w,
        o_par => s_addr
    );
    
    DATAPATH_comp : DATAPATH port map(
        i_clk => i_clk,
        i_rst => i_rst,
        done => done,
        i_data => i_mem_data,
        z0_load => z0_load,
        z1_load => z1_load,
        z2_load => z2_load,
        z3_load => z3_load,
        o_z0 => o_z0,
        o_z1 => o_z1,
        o_z2 => o_z2,
        o_z3 => o_z3,
        o_done => o_done
    );

    fsm : process(i_clk, i_rst)
    begin 
        if i_rst = '1' then
            curr_state <= WAIT_START;
        elsif i_clk'event and i_clk = '1' then
            case curr_state is
                when WAIT_START => 
                    if i_start = '1' then
                        curr_state <= ADD1;
                    else 
                        curr_state <= WAIT_START;
                    end if;
                when ADD1 =>
                    if i_start = '1' then
                        curr_state <= ADD2;
                    else 
                        curr_state <= WAIT_START;
                    end if;
                when ADD2 => 
                    curr_state <= LOAD_MEM;
                when LOAD_MEM =>
                    if i_start = '1' then
                        curr_state <= LOAD_MEM;
                    else 
                        curr_state <= SAVE_DATA;
                    end if;
                when SAVE_DATA =>
                    curr_state <= OUTPUT;
                when OUTPUT => 
                    curr_state <= WAIT_START;
            end case;
           end if;
    end process;
    
    lambda : process(curr_state, s_addr, d_sel) 
    begin
        s_w <= '0';
        s_rst <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        o_mem_addr <= (others => '0');
        done <= '0';
        z0_load <= '0';
        z1_load <= '0';
        z2_load <= '0';
        z3_load <= '0';
        d1_load <= '0';
        d0_load <= '0';
        
        case curr_state is
            when WAIT_START =>
                d1_load <= '1';
            when ADD1 => 
                s_rst <= '1';
                d0_load <= '1';
            when ADD2 => 
     
            when LOAD_MEM => 
                o_mem_en <= '1';
                o_mem_addr <= s_addr;
            when SAVE_DATA =>
                if d_sel = "00" then
                    z0_load <= '1';
                elsif d_sel = "01" then 
                    z1_load <= '1';
                elsif d_sel = "10" then
                    z2_load <= '1';
                else
                    z3_load <= '1';
                end if;
             when OUTPUT => 
                 done <= '1';                
             end case;
     end process;
     
     sel: process(i_clk, i_rst)
     begin
        if i_rst = '1' then
            d_sel <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if d0_load = '1' then
                d_sel(0) <= i_w;
            elsif d1_load = '1' then
                d_sel(1) <= i_w;
            end if;
        end if;
     end process; 
    
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    done : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    z0_load : in std_logic;
    z1_load : in std_logic;
    z2_load : in std_logic;
    z3_load : in std_logic;
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    o_done : out std_logic
);
end datapath;

architecture datapath_arch of datapath is
    signal z0 : std_logic_vector(7 downto 0) := "00000000";
    signal z1 : std_logic_vector(7 downto 0) := "00000000";
    signal z2 : std_logic_vector(7 downto 0) := "00000000";
    signal z3 : std_logic_vector(7 downto 0) := "00000000";
    
    begin 
    z0_p : process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            z0 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if z0_load = '1' then
                z0 <= i_data;
            end if;
        end if;
    end process;
    
    z1_p : process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            z1 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if z1_load = '1' then
                z1 <= i_data;
            end if;
        end if;
    end process;
    
    z2_p : process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            z2 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if z2_load = '1' then
                z2 <= i_data;
            end if;
        end if;
    end process;
    
    z3_p : process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            z3 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if z3_load = '1' then
                z3 <= i_data;
            end if;
        end if;
    end process;
    
    out_p : process(i_clk, done)
    begin 
        if i_clk'event and i_clk = '1' then
            if done = '1' then
                o_z0 <= z0;
                o_z1 <= z1;
                o_z2 <= z2;
                o_z3 <= z3;
                o_done <= '1';
            else 
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";
                o_done <= '0';
            end if;
        end if;
    end process;
end architecture;