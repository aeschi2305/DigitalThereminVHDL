onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /mixer_tb/clk
add wave -noupdate /mixer_tb/reset_n
add wave -noupdate /mixer_tb/square_freq
add wave -noupdate /mixer_tb/sine
add wave -noupdate /mixer_tb/mixer_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {18 ns} {51 ns}
