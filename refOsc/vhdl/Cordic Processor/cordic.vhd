-----------------------------------------------------
-- Project : Cordic Calculation N iterations parallel
-----------------------------------------------------
-- File    : cordic.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Calculates the sine value of a given angle phi in N parallel iterations (no pipelining)
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Cordic is
eneric (
    N : natural := 16 --Number of Bits of the sine wave (precision)

  );
  port(
    reset_n : in std_ulogic;
    clk : in std_ulogic;
    phi : in signed(N-1 downto 0);
    sine : out signed(N-1 downto 0)
  );
end entity Cordic;

architecture behavioral of Cordic is
type xyzPar is array (N-1 downto 0) of signed (N-1 downto 0);
signal xPar : xyzPipeline;
signal yPar : xyzPipeline;
signal zPar : xyzPipeline;

signal xreg : signed (N-1 downto 0);
signal yreg : signed (N-1 downto 0);
signal zreg : signed (N-1 downto 0);

procedure calculateIteration (
      xk    : in signed(N-1 downto 0);   -- input x-coordinates
      yk    : in signed(N-1 downto 0);   -- input y-coordinates
      zk    : in signed(N-1 downto 0);   -- input angle
      k     : in natural range 0 to N-1;   -- iteration index
      xkk   : out signed(N-1 downto 0);   -- output x-coordinates
      ykk   : out signed(N-1 downto 0);   -- output y-coordinates
      zkk   : out signed(N-1 downto 0)   -- output angle
    ) return std_ulogic_vector is
    type atan_type is array (0 to 14) of signed (N-1 downto 0);
    constant atan : atan_type :=     ("1100000000000000"  -- Lookuptable for the arcustangent of 2^-k
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
        if reset_n = '0' then

        elsif rising_edge(clk) then
            xreg <= xPar(0); 
            yreg <= yPar(0);
            zreg <= zPar(0);
        end if;
    end process p_reg;

    p_cmb : process(all)
    begin
        xPip1(15) <= 1;
        yPip1(15) <= 0;
        zPip1(15) <= phi;   
        l_cordic1 : for k in 15 downto 0 loop
            calculateIteration(xPar(k+1),yPar(k+1),zPar(k+1),k,xPar(k),yPar(k),zPar(k))
        end loop l_cordic1;

    end process p_cmb;

    sine <= yPip3(0)
            
end architecture behavioral;
