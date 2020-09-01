LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY crc IS
	PORT (input: IN STD_LOGIC_VECTOR(31 downto 0);
			output: OUT STD_LOGIC_VECTOR(31 downto 0);
			adr, wrt, reset: IN STD_LOGIC;
			clk: IN STD_LOGIC);
END crc;

ARCHITECTURE behavior OF crc IS

	SIGNAL clock, enable, do_xor: STD_LOGIC;
	SIGNAL counter: STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL message: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL generator: STD_LOGIC_VECTOR(7 downto 0);
	
BEGIN
	clock <= clk;
	do_xor <= message(31);
	enable <= generator(0) AND generator(7);
	
	PROCESS (clock)
	BEGIN
		IF (rising_edge(clock)) THEN
			IF (reset = '1') THEN
			-- reset
				message <= "00000000000000000000000000000000";
				generator <= "00000000";
				counter <= "00000";
			ELSIF (wrt = '1') THEN
			-- read
				IF (adr = '0') THEN
				-- read in message
					message <= input;
				ELSIF (adr = '1') THEN
				-- read in generator ploynom
					generator <= input(7 downto 0);
				END IF;
			ELSIF (enable = '1') THEN
			-- calculate crc
				IF (counter = "11001") THEN
				-- shifted 25 times -> finish calc
					generator <= "00000000";
					counter <= "00000";
					message(6 downto 0) <= message(31 downto 25);
					message(31 downto 7) <= "0000000000000000000000000";
					output <= message;
				ELSIF (do_xor = '1') THEN
					-- xor
					message(31 downto 24) <= message(31 downto 24) xor generator(7 downto 0);
				ELSE
					counter <= counter + 1;
					-- shift
					message(31 downto 1) <= message(30 downto 0);
					message(0) <= '0';
				END IF;
			ELSIF (adr = '1') THEN
				output(7 downto 0) <= generator;
				output(31 downto 8) <= "000000000000000000000000";
			ELSE
				output <= message;
			END IF;
		END IF;
	END PROCESS;
	
END behavior;