library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_calc_pos is
 port (
            detecteur                   : in    std_logic_vector(6 downto 0);              
            nbr_1                       : out   std_logic_vector(2 downto 0); 
            sig_err                     : out   std_logic_vector(3 downto 0)
        );

end test_calc_pos;

architecture test of test_calc_pos is 

--signal sig_capteurs : std_logic_vector(6 downto 0);
--signal sig_data0d : unsigned(55 downto 0);
--signal sig_pos : unsigned(3 downto 0);
--signal nbr1 : unsigned(2 downto 0);


begin
  proc: PROCESS (detecteur)
  variable PDU : integer;
  variable PPU : integer;
  variable nb : integer;
  variable flag1 : boolean;
  variable flag2 : boolean;
	begin
	PDU :=0;
	PPU :=0;
	nb :=0;
	flag1 :=false;
	flag2 :=false;
	
		loopl: For i in 0 to 6 LOOP
				if detecteur(i)='1' then
					if not flag1 then 
						PPU:=i;
						flag1 := true;
					end if;
					nb := nb +1;
				end if;
				
				if detecteur(6-i)='1' and not flag2 then
					flag2 := true;
					PDU:=6-i;
				end if;
				
--				if i=0 then
--					if (detecteur(i)='1' and detecteur(i+1)='1' )then
--						capteur1:=capteur1+1;
--					end if;
--				elsif not flag2 and ((detecteur(i)='1' and detecteur(i+1)='1' ) or (detecteur(i)='1' and detecteur(i-1)='1' ))then
--					capteur1:=capteur1+1;
--				end if;
		end loop loopl;
		
		
		
		nbr_1 <=	std_logic_vector(to_signed(nb,3));   
		sig_err <=	std_logic_vector(to_signed(PPU+PDU-6,4));
	
	END PROCESS proc;
end test;
		
					
				
						
  
  

