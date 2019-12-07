onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
radix define fixed#28#decimal#signed -fixed -fraction 28 -signed -base signed -precision 6
radix define fixed#16#decimal#signed -fixed -fraction 16 -signed -base signed -precision 6
radix define fixed#20#decimal#signed -fixed -fraction 20 -signed -base signed -precision 6
radix define fixed#19#decimal#signed -fixed -fraction 19 -signed -base signed -precision 6
radix define fixed#40#decimal#signed -fixed -fraction 40 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /cordic_control_tb/clk
add wave -noupdate /cordic_control_tb/reset_n
add wave -noupdate -format Analog-Step -height 74 -max 0.99996900000000022 -min -1.0 /cordic_control_tb/phi
add wave -noupdate -format Analog-Step -height 74 -max 0.99993900000000013 -min -0.99993900000000002 /cordic_control_tb/sine
add wave -noupdate -radix decimal /cordic_control_tb/control_pm/sig_Freq
add wave -noupdate /cordic_control_tb/control_pm/phi_step
add wave -noupdate /cordic_control_tb/control_pm/phi_noninv_cmb
add wave -noupdate -format Analog-Step -height 74 -max 1.99997 -min -1.99997 /cordic_control_tb/control_pm/phi_noninv_reg
add wave -noupdate /cordic_control_tb/verify_pm/count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {3228650 ps} 0} {{Cursor 5} {977765110 ps} 0} {{Cursor 3} {5069670 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
configure wave -valuecolwidth 151
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
WaveRestoreZoom {0 ps} {35632 ns}
