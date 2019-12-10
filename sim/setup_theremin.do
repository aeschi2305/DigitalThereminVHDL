onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
radix define fixed#28#decimal#signed -fixed -fraction 28 -signed -base signed -precision 6
radix define fixed#16#decimal#signed -fixed -fraction 16 -signed -base signed -precision 6
radix define fixed#20#decimal#signed -fixed -fraction 20 -signed -base signed -precision 6
radix define fixed#19#decimal#signed -fixed -fraction 19 -signed -base signed -precision 6
radix define fixed#40#decimal#signed -fixed -fraction 40 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /theremin_tb/reset_n
add wave -noupdate /theremin_tb/clk
add wave -noupdate -format Analog-Step -height 74 -max 0.99996900000000022 -min -1.0 /theremin_tb/phi
add wave -noupdate -format Analog-Step -height 74 -max 0.99993900000000013 -min -0.99993900000000002 /theremin_tb/sine
add wave -noupdate -radix binary /theremin_tb/square_freq
add wave -noupdate -format Analog-Step -height 74 -max 0.99993900000000013 -min -0.99993900000000002 /theremin_tb/mixer_out
add wave -noupdate -format Analog-Step -height 74 -max 20807800.0 -min -19232900.0 -radix decimal /theremin_tb/audio_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Square 1} {1040120 ps} 0} {{Square 2} {3035640 ps} 0} {{Cursor 5} {312664350 ps} 0} {{Cursor 6} {1771521750 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 256
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {3690987520 ps}
