library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_wrapper is
	port(
		clk: in std_logic;
		LED: out std_logic_vector(9 downto 0)
	);
end entity;

architecture arch of test_wrapper is
	signal pulse_pass, flag, pol: std_logic;
	signal clk_div: std_logic_vector(15 downto 0);
	signal duty_cycle: std_logic_vector(9 downto 0);
	
component pwm is
	generic(
		max_val: integer := 1000;
		val_bits: integer := 10
	);
	port(
		clk: in std_logic;
		val_cur: in std_logic_vector((val_bits -1) downto 0);
		pulse: out std_logic
	);
end component;	
	
begin

LED <= (others => pulse_pass);

process(clk) -- Clock Divide
begin
	if(clk'event and clk = '1') then
		if (clk_div < 49_999) then
			clk_div <= clk_div + 1;
			flag <= '0';
		else
			clk_div <= (others => '0');
			flag <= '1';
		end if;
	end if;
end process;

process(clk) -- Duty Cycle
begin
	if(clk'event and clk = '1') then
		if (flag = '1') then -- 1ms Pulse
			if (pol = '0') then -- Polarity
				if (duty_cycle < 999) then
					duty_cycle <= duty_cycle + 1;
					pol <= '0';
				else
					pol <= '1';
				end if;
			else
				if (duty_cycle > 1) then
					duty_cycle <= duty_cycle - 1;
					pol <= '1';
				else
					pol <= '0';
				end if;
			end if;
		end if;
	end if;
end process;

pwm0: pwm
generic map(
	max_val => 1000,
	val_bits => 10
	)
port map(
	clk => clk,
	val_cur => duty_cycle,
	pulse => pulse_pass
	);

end arch;