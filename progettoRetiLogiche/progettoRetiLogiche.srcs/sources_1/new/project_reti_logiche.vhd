
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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

begin


end Behavioral;


library ieee;
use ieee.std_logic_1164.all;

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
