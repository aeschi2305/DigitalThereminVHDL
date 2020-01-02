-----------------------------------------------------
-- Project : Cordic Calculation
-----------------------------------------------------
-- File    : cordic.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Calculates the sine value of a given angle phi
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Cordic is
eneric (
		N : natural := 16	--Number of Bits of the sine wave (precision)

	);
  port(
    reset : in std_ulogic;
    clk : in std_ulogic;
    phi : in signed(N-1 downto 0);
    sine : out signed(N-1 downto 0)
  );
end entity Cordic;

architecture behavioral of Cordic is
type xyzPipeline is array (5 downto 0) of signed (N-1 downto 0);
signal xPip1 : xyzPipeline;
signal xPip2 : xyzPipeline;
signal xPip3 : xyzPipeline;
signal yPip1 : xyzPipeline;
signal yPip2 : xyzPipeline;
signal yPip3 : xyzPipeline;
signal zPip1 : xyzPipeline;
signal zPip2 : xyzPipeline;
signal zPip3 : xyzPipeline;
signal xreg1 : signed (N-1 downto 0);
signal xreg2 : signed (N-1 downto 0);
signal xreg3 : signed (N-1 downto 0);
signal yreg1 : signed (N-1 downto 0);
signal yreg2 : signed (N-1 downto 0);
signal yreg3 : signed (N-1 downto 0);
signal zreg1 : signed (N-1 downto 0);
signal zreg2 : signed (N-1 downto 0);
signal zreg3 : signed (N-1 downto 0);


procedure calculateIteration (
      xk    : in signed(N-1 downto 0);   -- input x-coordinates
      yk    : in signed(N-1 downto 0);   -- input y-coordinates
      zk    : in signed(N-1 downto 0);   -- input angle
      k     : in natural range 0 to 15;   -- iteration index
      xkk   : out signed(N-1 downto 0);   -- output x-coordinates
      ykk   : out signed(N-1 downto 0);   -- output y-coordinates
      zkk   : out signed(N-1 downto 0)   -- output angle
    ) return std_ulogic_vector is
    type atan_type is array (0 to 15) of signed (N-1 downto 0);
    constant atan : atan_type :=     ("1100000000000000"
    								  "1010010111001000"
    								  "1001001111110110"
    								  "1000101000100010"
    								  "1000010100010110"
    								  "1000001010001011"
    								  "1000000101000101"
    								  "1000000010100010"
    								  "1000000001010001"
    								  "1000000000101000"
    								  "1000000000010100"
    								  "1000000000001010"
    								  "1000000000000101"
    								  "1000000000000010"
    								  "1000000000000001"
);
  begin
    if zk > '0' then
        xkk <= xk - shift_right(yk,k);
        ykk <= yk + shift_right(xk,k);
        zkk <= zk - atan(k)
    else
        xkk <= xk + shift_right(yk,k);
        ykk <= yk - shift_right(yk,k);
        zkk <= zk + atan(k)
    end if;

  end procedure calculateIteration;

begin

    p_reg : process(reset,clk)
    begin
        if reset = '1' then

        elsif rising_edge(clk) then
            xreg1 <= xPip1(0); 
            xreg2 <= xPip2(0);
            yreg1 <= yPip1(0); 
            yreg2 <= yPip2(0);
            zreg1 <= zPip1(0); 
            zreg2 <= zPip2(0);
        end if;
    end process p_reg;

    p_cmb : process(all)
    begin
        xPip1(5) <= 1;
        yPip1(5) <= 0;
        zPip1(5) <= phi;   
        l_cordic1 : for k in 4 downto 0 loop
            calculateIteration(xPip1(k+1),yPip1(k+1),zPip1(k+1),k,xPip1(k),yPip1(k),zPip1(k))
        end loop l_cordic1;


        xPip2(5) <= xreg1;
        yPip2(5) <= yreg1;
        zPip2(5) <= zreg1;   
        l_cordic2 : for k in 4 downto 0 loop
            calculateIteration(xPip2(k),yPip2(k),zPip2(k),k+5,xPip2(k+1),yPip2(k+1),zPip2(k+1))
        end loop l_cordic2;


        xPip3(5) <= xreg2;
        yPip3(5) <= yreg2;
        zPip3(5) <= zreg2;   
        l_cordic3 : for k in 4 downto 0 loop
            calculateIteration(xPip3(k),yPip3(k),zPip3(k),k+10,xPip3(k+1),yPip3(k+1),zPip3(k+1))
        end loop l_cordic3;
    end process p_cmb;

    sine <= yPip3(0)
            
end architecture behavioral;
