----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/22/2019 08:37:38 PM
-- Design Name: 
-- Module Name: MathFunctions - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package MathFunctions is
    function getVectorSize( maxValue : integer) return integer;
end package MathFunctions;

package body MathFunctions is

    function getVectorSize( maxValue : integer) return integer is
        variable vectorSize : integer := 1;
    begin
        while 2**vectorSize <= maxValue loop
            vectorSize := vectorSize + 1;
        end loop;
        return vectorSize;
    end getVectorSize;

end package body;
