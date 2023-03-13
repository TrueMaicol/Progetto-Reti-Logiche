
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial_to_parallel is port (
    i_clk : in std_logic;
    i_rst: in std_logic;
    i_w : in std_logic;
	o_par : out std_logic_vector(15 downto 0));
end serial_to_parallel;

architecture Behavioral of serial_to_parallel is
	signal temp: std_logic_vector(15 downto 0);
	begin
		process(i_clk)
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
    o_mem_en : out std_logic ); 
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    component SHIFTER_comp is port (
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_w : in std_logic;
        o_par : out std_logic_vector(15 downto 0)
    );
    end component;
    component DATAPATH_comp is port ( 
        r0_load : in std_logic;
        r1_load : in std_logic;
        r2_load : in std_logic;
        r3_load : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0)
    );
    end component;
    
    type S is (S0,S1,S2,S3,S4,S5);
    signal curr_state : S;
    signal s_w : std_logic;
    signal s_rst : std_logic;
    signal s_addr : std_logic_vector(15 downto 0);
    signal done : std_logic;
    signal r0_load : std_logic;
    signal r1_load : std_logic;
    signal r2_load : std_logic;
    signal r3_load : std_logic;
    signal d_sel : std_logic_vector(1 downto 0);
    
begin
    SHIFTER : SHIFTER_comp port map(
        i_clk,
        i_rst,
        s_w,
        s_addr
    );
    
    DATAPATH : DATAPATH_comp port map(
        r0_load,
        r1_load,
        r2_load,
        r3_load,
        o_z0,
        o_z1,
        o_z2,
        o_z3
    );

    fsm : process(i_clk, i_rst)
    begin 
        if i_rst = '0' then
            curr_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            case i_start is 
                when '1' =>
                    case curr_state is
                        when S0 =>
                            curr_state <= S1;
                        when S1 =>
                            curr_state <= S2;
                        when S2 =>
                            curr_state <= S3;
                        when S3 =>
                            curr_state <= S3;
                        when S4 =>
                            curr_state <= S0;
                        when S5 =>
                            curr_state <= S0;
                    end case;
                when '0' =>
                    case curr_state is
                        when S0 =>
                            curr_state <= S0;
                        when S1 =>
                            curr_state <= S0;
                        when S2 =>
                            curr_state <= S0;
                        when S3 =>
                            curr_state <= S4;
                        when S4 =>
                            curr_state <= S5;
                        when S5 =>
                            curr_state <= S0;
                    end case; 
               end case;
           end if;
    end process;
    
    lambda : process(curr_state) 
    begin
        s_w <= '0';
        s_rst <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        o_mem_addr <= (others => '0');
        done <= '0';
        r0_load <= '0';
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        
        case curr_state is
            when S0 =>
                d_sel <= "00";
            when S1 => 
                d_sel(1) <= i_w;
            when S2 => 
                d_sel(0) <= i_w;
                s_rst <= '1';
            when S3 => 
                s_w <= i_w;
            when S4 =>
                o_mem_en <= '1';
                o_mem_addr <= s_addr;
                if d_sel = "00" then
                    r0_load <= '1';
                elsif d_sel = "01" then 
                    r1_load <= '1';
                elsif d_sel = "10" then
                    r2_load <= '1';
                else
                    r3_load <= '1';
                end if;
             when S5 => 
                o_done <= '1';
                done <= '1';
             end case;
             end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is port (
    r0_load : in std_logic;
    r1_load : in std_logic;
    r2_load : in std_logic;
    r3_load : in std_logic;
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0)
);
end datapath;

architecture datapath_arch of datapath is
    begin 
    ...
end architecture;
