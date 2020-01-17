-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : cordic_pipelined.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Calculates the sine value of a given angle phi in (N-1)/3 stages for the reference oscillator
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_pipelined is
  generic (
    N : natural := 16; --Number of Bits of the sine wave (precision)
    stages : natural := 3
  );
  port(
    reset_n : in std_ulogic;
    clk : in std_ulogic;
    phi : in signed(N-1 downto 0);
    sine : out signed(N-1 downto 0)
  );
end entity cordic_pipelined;

architecture behavioral of cordic_pipelined is
type atan_type is array (0 to 14) of signed (N-1 downto 0);
constant atan : atan_type :=     ("0100000000000000",  -- Lookuptable for the arcustangent of 2^(-k)
                                  "0010010111001000",
                                  "0001001111110110",
                                  "0000101000100010",
                                  "0000010100010110",
                                  "0000001010001011",
                                  "0000000101000101",
                                  "0000000010100010",
                                  "0000000001010001",
                                  "0000000000101000",
                                  "0000000000010100",
                                  "0000000000001010",
                                  "0000000000000101",
                                  "0000000000000010",
                                  "0000000000000001");


signal cnt : integer range 0 to 15;


--record for a cordic calculation of one input value
type cordic_record is record
    x : signed (N downto 0);
    y : signed (N downto 0);
    z : signed (N-1 downto 0);
end record cordic_record;

type cordic_cmb_record_array is array (N-2 downto 0) of cordic_record;
type cordic_reg_record_array is array (stages downto 0) of cordic_record;

constant icordic_reg : cordic_record  := (x => (others => '0'),
                                          y => (others => '0'),
                                          z => (others => '0'));

constant An : signed(N downto 0) := "00100110110111010";		-- scaling Factor

signal cordic_rec_reg : cordic_reg_record_array;
signal cordic_rec_cmb : cordic_cmb_record_array;

signal cordic_cmb : signed(2*N+1 downto 0);
signal cordic_reg : signed(N-1 downto 0);

  ------------------------------------------------------------------------------
  -- Cordic algorithm function
  ------------------------------------------------------------------------------

function calculateIteration (        --calculation of one Iteration
     cordic_rec : cordic_record;   	--
     k : integer					-- iteration index
)
return cordic_record is
  variable v_record : cordic_record;
  variable xx : signed(N downto 0);
  begin
    v_record := cordic_rec;
    if v_record.z(v_record.z'left) = '0' then           -- is zk positive
        xx := v_record.x - shift_right(v_record.y,k);    
        v_record.y := v_record.y + shift_right(v_record.x,k);
        v_record.z := v_record.z - atan(k);
    else
        xx := v_record.x + shift_right(v_record.y,k);
        v_record.y := v_record.y - shift_right(v_record.x,k);
        v_record.z := v_record.z + atan(k);
    end if;
    v_record.x := xx;
    return v_record;
  end function calculateIteration;

begin
    

  ------------------------------------------------------------------------------
  -- Registerd Process 
  ------------------------------------------------------------------------------
    p_reg : process(reset_n,clk)
    begin
        if reset_n = '0' then
            cordic_rec_reg <= (others => icordic_reg); 
            cordic_reg  <= (others => '0');
        elsif rising_edge(clk) then
              cordic_rec_reg(0).x <= "00"&(N-2 downto 0 => '1');    -- initialization of x-Variable  
              cordic_rec_reg(0).y <= (others => '0');				-- initialization of y-Variable  
              cordic_rec_reg(0).z <= phi; 							-- initialization of z-Variable  (angle)
              l_cordic_reg : for i in 1 to stages loop
                cordic_rec_reg(i) <= cordic_rec_cmb((N-1)/stages*i-1);	
              end loop l_cordic_reg;         
              cordic_reg <= cordic_cmb(2*N-2 downto N-1);
        end if;
    end process p_reg;


  ------------------------------------------------------------------------------
  -- Combinatorial Processes
  ------------------------------------------------------------------------------

  --Calculates pipelined stages
    p_cmb_cordic : process(all)

    begin 
    l_stages : for ii in 0 to stages-1 loop
        cordic_rec_cmb(((N-1)/stages)*ii) <= calculateIteration(cordic_rec_reg(ii),((N-1)/stages)*ii);
        l_cordic : for i in 0 to (N-1)/stages-2 loop
            cordic_rec_cmb(i+((N-1)/stages)*ii+1) <= calculateIteration(cordic_rec_cmb(i+((N-1)/stages)*ii),i+((N-1)/stages)*ii+1);
        end loop l_cordic;
    end loop l_stages;
    	
    end process p_cmb_cordic;

   --multiplies result from cordic with scaling factor
    p_cmb_scaling : process(all)

    begin 
      cordic_cmb <=   cordic_rec_reg(stages).y * An;    
    end process p_cmb_scaling;

  ------------------------------------------------------------------------------
  -- Output Assignments
  ------------------------------------------------------------------------------
    sine <= cordic_reg;

    
            
end architecture behavioral;
