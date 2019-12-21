-- Converted from DE0_Nano_Computer.v
-- by Verilog2VHDL ver1.00(2004/05/06)  Copyright(c) S.Morioka (http://www02.so-net.ne.jp/~morioka/v2v.htm)


-- Inputs


--****************************************************************************/
-- Bidirectionals


--  Memory (SDRAM)


--****************************************************************************/
-- Outputs
-- 	Simple


--  Memory (SDRAM)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE0_Nano_Computer is
	port (
		CLOCK_50	: in  std_logic;
		KEY	: in  std_logic_vector(1 downto 0);
		SW	: in  std_logic_vector(3 downto 0);
		ADC_SDAT	: in  std_logic;
		G_SENSOR_INT	: in  std_logic;

	-- GPIO_0 connecteur vers SCD robot
		BUZZER_OUT 			: out std_logic;
		IR_LED_ON 			: out std_logic;
		IR_RXD 				: in std_logic;
		LED_LEFT 			: out std_logic;
		LED_RIGHT 			: out std_logic;
		LTC_ADC_CONVST 	: out std_logic;
		LTC_ADC_SCK 		: out std_logic;
		LTC_ADC_SDI 		: out std_logic;
		LTC_ADC_SDO 		: in std_logic;
		MTRL_N 				: out std_logic;
		MTRL_P 				: out std_logic;
		MTRR_N 				: out std_logic;
		MTRR_P 				: out std_logic;
		MTR_Fault_n 		: in std_logic;
		MTR_Sleep_n 		: out std_logic;
		TMD0 : inout std_logic_vector(7 downto 0);
		TMD1: inout std_logic_vector(7 downto 0);
		VCC3P3_PWRON_n 	: out std_logic;

	--  Memory (SDRAM)
		DRAM_DQ	: inout std_logic_vector(15 downto 0);

	-- Outputs
	-- 	Simple
		LEDG	: out std_logic_vector(7 downto 0);
		ADC_SADDR	: out std_logic;
		ADC_SCLK	: out std_logic;
		ADC_CS_N	: out std_logic;
		G_SENSOR_CS_N	: out std_logic;
		I2C_SCLK	: out std_logic;
		I2C_SDAT	: inout std_logic;

	--  Memory (SDRAM)
		DRAM_ADDR	: out std_logic_vector(12 downto 0);
		DRAM_BA	: out std_logic_vector(1 downto 0);
		DRAM_CLK	: out std_logic;
		DRAM_CKE	: out std_logic;
		DRAM_CS_N	: out std_logic;
		DRAM_CAS_N	: out std_logic;
		DRAM_RAS_N	: out std_logic;
		DRAM_WE_N	: out std_logic;
		DRAM_DQM	: out std_logic_vector(1 downto 0) 

	);
	
end DE0_Nano_Computer;

--library work;
--use work.all;

----------------------------------------------------------
  -- ARChitecture
----------------------------------------------------------
architecture RTL of DE0_Nano_Computer is

signal irm_key, CLK_SDRAM_o,oDATA_REAY,iREAD : std_logic;
signal irm_data : std_logic_vector(7 downto 0);
signal ident_tele : std_logic_vector(7 downto 0);
signal capture_capt,readyr_capt : std_logic :='0';
signal data0d,data1d : std_logic_vector(55 downto 0);
signal clk_40Mhz,clk_2k : std_logic :='0';
signal detecteur : std_logic_vector(6 downto 0);
constant NIVEAU : std_logic_vector(7 downto 0) := X"20";
signal ordre_moteur_R,ordre_moteur_L : std_logic_vector(13 downto 0);
signal pilote_moteur: std_logic_vector( 31 downto 0);
signal capt3, sig_input:std_logic_vector (31 downto 0);
signal capt6:std_logic_vector (31 downto 0);
--signal detecteur : std_logic_vector(6 downto 0);
signal nb_un : std_logic_vector(2 downto 0);
signal erreur : std_logic_vector(3 downto 0);

		component pll_2freqs 
				PORT
				(
				areset		: IN STD_LOGIC  := '0';
				inclk0		: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC ;
				c1		: OUT STD_LOGIC 
				);
		END component;

		
		component capteurs_sol_seuil
			port (
				clk	: in  std_logic;	-- max 40mhz
				reset_n	: in  std_logic;
			--
				data_capture	: in  std_logic;	-- rise edge to trigger
				data_readyr	: out std_logic;
				data0r	: out std_logic_vector(7 downto 0);
				data1r	: out std_logic_vector(7 downto 0);
				data2r	: out std_logic_vector(7 downto 0);
				data3r	: out std_logic_vector(7 downto 0);
				data4r	: out std_logic_vector(7 downto 0);
				data5r	: out std_logic_vector(7 downto 0);
				data6r	: out std_logic_vector(7 downto 0);
			-- seuillage
			   NIVEAU : in std_logic_vector(7 downto 0);
		      vect_capt : out std_logic_vector(6 downto 0);
			-- spi 
				ADC_CONVSTr	: out std_logic;
				ADC_SCK	: out std_logic;
				ADC_SDIr	: out std_logic;
				ADC_SDO	: in  std_logic 
				);
		end component;

	component IRDA_RECEIVER_id
	port (
		iCLK	: in  std_logic;	--input clk,50MHz
		iRST_n	: in  std_logic;	--rst
		iIRDA	: in  std_logic;	--Irda RX output decoded data
		oDATA_READY	: out std_logic;	--data ready flag
		oDATA	: out std_logic_vector(7 downto 0); 	--output data ,8bits 		
		-- selecteur telecommande
		select_id : in std_logic_vector(7 downto 0);
		-- identifiant telecommande
		ir_id : out std_logic_vector(7 downto 0)

	);
	end component;
	
	component PWM_generation
	port(clk,reset_n:in std_logic;
			s_writedataR,s_writedataL: in std_logic_vector(13 downto 0);		-- Le bit13 : bit de go(1)/stop(0). Le bit12: bit de forward(0)/backward(1). Les bits 11 à 0: vitesse=durée état haut (en nombre de périodes d'horloge FPGA 50 MHz)
			dc_motor_p_R,dc_motor_n_R, dc_motor_p_L,dc_motor_n_L: out std_logic
			);
end component;


------------------------------------------------------------------------------
--  Processeur 
------------------------------------------------------------------------------
	component nios_system is
        port (
            zs_addr_from_the_SDRAM      : out   std_logic_vector(12 downto 0);                    -- addr
            zs_ba_from_the_SDRAM        : out   std_logic_vector(1 downto 0);                     -- ba
            zs_cas_n_from_the_SDRAM     : out   std_logic;                                        -- cas_n
            zs_cke_from_the_SDRAM       : out   std_logic;                                        -- cke
            zs_cs_n_from_the_SDRAM      : out   std_logic;                                        -- cs_n
            zs_dq_to_and_from_the_SDRAM : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            zs_dqm_from_the_SDRAM       : out   std_logic_vector(1 downto 0);                     -- dqm
            zs_ras_n_from_the_SDRAM     : out   std_logic;                                        -- ras_n
            zs_we_n_from_the_SDRAM      : out   std_logic;                                        -- we_n
            reset_n                     : in    std_logic                     := 'X';             -- reset_n
            clk                         : in    std_logic                     := 'X';             -- clk
            sdram_clk                   : out   std_logic;                                        -- clk
            omoteurctr_export           : out   std_logic_vector(31 downto 0);                    -- export
            ocapt3_export               : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            ocapteur6_export               : in    std_logic_vector(31 downto 0) := (others => 'X')  -- export
        );
    end component nios_system;

	component calculateur is
		port(
		detecteur1 : in std_logic_vector(6 downto 0);
		eerreur : out std_logic_vector(3 downto 0);
		nombre_de_1 : out std_logic_vector(2 downto 0)
		);
	end component;
--****************************************************************************
-- *                           Parameter Declarations                          *
-- *****************************************************************************/
attribute keep: boolean;
attribute keep of clk_40Mhz,clk_2k : signal is true;

--****************************************************************************
--****************************************************************************
begin
-- Allumage des LED infrarouges sur les capteurs
	 IR_LED_ON<='1';	
---- Pour alimenter la carte fille de pilotage du robot
	VCC3P3_PWRON_n <= '0';
----  horloge de la SDRAM externe au FGPA	 
   DRAM_CLK<= CLK_SDRAM_o;
	
---- gestion du des moteur, controle moteur ON
		MTR_Sleep_n <='1';
			
------- le systeme NIOS II	 
	NiosII: nios_system
	port map (
		-- 1) global signals:
		clk	=> CLOCK_50,
		reset_n	=> KEY(0),
		sdram_clk	=> CLK_SDRAM_o,
		-- the SDRAM
		zs_addr_from_the_SDRAM	=> DRAM_ADDR,
		zs_ba_from_the_SDRAM	=> DRAM_BA,
		zs_cas_n_from_the_SDRAM	=> DRAM_CAS_N,
		zs_cke_from_the_SDRAM	=> DRAM_CKE,
		zs_cs_n_from_the_SDRAM	=> DRAM_CS_N,
		zs_dq_to_and_from_the_SDRAM	=> DRAM_DQ,
		zs_dqm_from_the_SDRAM	=> DRAM_DQM,
		zs_ras_n_from_the_SDRAM	=> DRAM_RAS_N,
		zs_we_n_from_the_SDRAM	=> DRAM_WE_N,
		-----------		
		-- On ajoutera ici les interfaces avec les periphérique du robot
		omoteurctr_export           =>   pilote_moteur,    --       omoteurctr.export
		ocapt3_export               =>   data0d(31 downto 0),    -- export
		ocapteur6_export					 =>   sig_input    --export
		-----------		

	);
	
sig_input <= '0'&nb_un&erreur&data0d(55 downto 32);
--- recepteur telecommande
  p : IRDA_RECEIVER_id port map(
					iCLK => CLOCK_50,
					iRST_n => KEY(0),
					iIRDA => IR_RXD,
					oDATA_READY => oDATA_REAY,	 -- //data ready
					oDATA => irm_data,    --     //decode data output
					select_id => X"FF",
					ir_id => ident_tele
					);

--  capteur Sol	
	 capt:  capteurs_sol_seuil  port map (
				clk => clk_40Mhz,-- max 40mhz
				reset_n => KEY(0),
				data_capture => clk_2k,	-- rise edge to trigger
				data_readyr => readyr_capt,
				data0r => data0d(7 downto 0),
				data1r => data0d(15 downto 8),
				data2r => data0d(23 downto 16),
				data3r => data0d(31 downto 24),
				data4r => data0d(39 downto 32),
				data5r => data0d(47 downto 40),
				data6r => data0d(55 downto 48),
			-- partie seuillage
				NIVEAU => NIVEAU,
				vect_capt => detecteur,
			-- spi 
				ADC_CONVSTr => LTC_ADC_CONVST,
				ADC_SCK => LTC_ADC_SCK,
				ADC_SDIr => LTC_ADC_SDI,
				ADC_SDO => LTC_ADC_SDO
				);
				
	 
-- PLL pour générer les horloges pour le module d'acquisition des données des 7 capteurs(brique "capteurs_sol")
	 freq : pll_2freqs PORT MAP (
				areset	 => not(KEY(0)),
				inclk0	 => CLOCK_50,
				c0	 => clk_40Mhz,
				c1 => clk_2k
				);

-- Commande finale des moteurs	
		moteur : PWM_generation	port map(
				clk => CLOCK_50,
				reset_n => Key(0),--reset_n_test,--
				s_writedataR => ordre_moteur_R,
				s_writedataL => ordre_moteur_L,
				dc_motor_p_R => MTRR_P,
				dc_motor_n_R => MTRR_N,
				dc_motor_p_L => MTRL_P,
				dc_motor_n_L => MTRL_N
				); 	
		
	Calc_pos: entity work.calculateur(arch)
	port map( detecteur1 => detecteur, eerreur => erreur, nombre_de_1 => nb_un);
	
	ordre_moteur_R<= pilote_moteur(13 downto 0);
	ordre_moteur_L<= pilote_moteur(29 downto 16);
	--capt3 <= data0d (31 downto 0);
	--capt6 <=  '0' & nb_un & erreur & data0d(55 downto 32);
	--capt6 <= data0d (31 downto 0);
-- selecteur pour afficher ce qu'on veut sur les LEDs	 
--	LEDG<= 	data0d(7 downto 0) when irm_data=X"00" else
--			data0d(15 downto 8)when irm_data=X"01" else
--			data0d(23 downto 16)when irm_data=X"02" else
--			data0d(31 downto 24)when irm_data=X"03" else
--			data0d(39 downto 32) when irm_data=X"04" else
--			data0d(47 downto 40)when irm_data=X"05" else
--			data0d(55 downto 48)when irm_data=X"06" else
--			'0'&nb_un & erreur when irm_data=X"09" else
--			X"00";
		LEDG <= sig_input(31 downto 24);

end RTL;

--architecture carac_calculateur of DE0_Nano_Computer is
--
--component calculateur is
--	port(
--	detecteur : in std_logic_vector(6 downto 0);
--	eerreur : out std_logic_vector(3 downto 0);
--	nombre_de_1 : out std_logic_vector(2 downto 0)
--	);
--end component;
--
--signal detecteur : std_logic_vector(6 downto 0);
--signal nb_un : std_logic_vector(2 downto 0);
--signal erreur : std_logic_vector(3 downto 0);
--
--begin
--
--	C1: entity work.calculateur(arch)
--	port map( detecteur => detecteur, eerreur => erreur, nombre_de_1 => nb_un);
--	
--	P1: process(clock_50)
--	begin
--		if (CLOcK_50'event and CLOCK_50 = '1') then
--			detecteur <= SW(2 downto 0) & SW (3 downto 0);
--			LEDG(6 downto 0) <= nb_un & erreur;
--		end if;
--	end process;
--	
--end carac_calculateur;
