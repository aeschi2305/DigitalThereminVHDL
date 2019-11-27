onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /cordic_tb/clk
add wave -noupdate /cordic_tb/reset_n
add wave -noupdate /cordic_tb/sine
add wave -noupdate /cordic_tb/verify_pm/count
add wave -noupdate /cordic_tb/verify_pm/phi
add wave -noupdate /cordic_tb/cordic_pm/cordic_rec_reg
add wave -noupdate /cordic_tb/cordic_pm/done
add wave -noupdate /cordic_tb/cordic_pm/cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
configure wave -valuecolwidth 154
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
WaveRestoreZoom {0 ns} {146 ns}
