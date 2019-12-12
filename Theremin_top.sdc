#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20 -name clk [get_ports {clk}] #50MHz
create_clock -period 20.8333 -name clk_48 [get_ports {clk_48}] #48MHz
create_clock -period 81.38 -name audio_clk_clk [get_ports {audio_clk_clk}] #12.288MHz

#**************************************************************
# Clock groups
#**************************************************************
set_clock_groups –asynchronous –group [get_clocks clk] –group
[get_clocks clk_48]

set_clock_groups –asynchronous –group [get_clocks clk_48] –group
[get_clocks audio_clk_clk]

derive_pll_clocks
derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************
set_false_path -from key[*]
set_false_path -from [get_ports {square_freq}]

#**************************************************************
# Set Output Delay
#**************************************************************
#synchron or asynchron I2C I2S
set_false_path -to [get_ports {square_freq}]
set_false_path -to ledr[*]