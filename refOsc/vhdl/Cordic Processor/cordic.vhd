-----------------------------------------------------
-- Project : Digital Theremin
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
  generic (
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
type atan_type is array (0 to 14) of signed (N-1 downto 0);
constant atan : atan_type :=     ("0100000000000000",  -- Lookuptable for the arcustangent of 2^-k
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

--type xyzPar is array (N downto 0) of signed (N-1 downto 0);
--signal xPar : xyzPar;
--signal yPar : xyzPar;
--signal zPar : xyzPar;
signal ycmb : signed (N-1 downto 0);

--signal xreg : signed (N-1 downto 0);    --only needed if pipelined
signal yreg : signed (N-1 downto 0);
--signal zreg : signed (N-1 downto 0);    --only needed if pipelined





procedure calculateIteration (        --calculation of one Iteration
      x   : inout signed(N-1 downto 0);   -- output x-coordinates
      y   : inout signed(N-1 downto 0);   -- output y-coordinates
      z   : inout signed(N-1 downto 0);   -- output angle
      k   : in natural range 0 to N   -- iteration index
      

)is

  begin
    if z(z'left) = '0' then           -- is zk positive
        x := x - shift_right(y,k);    
        y := y + shift_right(x,k);
        z := z - atan(k);
    else
        x := x + shift_right(y,k);
        y := y - shift_right(x,k);
        z := z + atan(k);
    end if;

  end procedure calculateIteration;

begin

    p_reg : process(reset_n,clk)
    begin
        if reset_n = '0' then
            --xreg <= (others => '0');    --only needed if pipelined
            yreg <= (others => '0');
            --zreg <= (others => '0');    --only needed if pipelined
        elsif rising_edge(clk) then
            --xreg <= xPar(0);            --only needed if pipelined
            yreg <= ycmb;
            --zreg <= zPar(0);            --only needed if pipelined
        end if;
    end process p_reg;

    p_cmb : process(all)
        variable x : signed(N-1 downto 0);
        variable y : signed(N-1 downto 0);
        variable z : signed(N-1 downto 0);
    begin

        x := (others => '0');
        x(0) := '1';
        y := (others => '0');
        z := phi;   
        l_cordic1 : for k in N-1 downto 0 loop
            calculateIteration(x,y,z,k);
        end loop l_cordic1;
        --xcmb <= x;
        ycmb <= y;
        --zcmb <= z;

    end process p_cmb;

    sine <= yreg;
            
end architecture behavioral;
