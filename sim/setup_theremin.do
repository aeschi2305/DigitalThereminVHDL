onerror {resume}
radix define fixed#15#decimal -fixed -fraction 15 -base signed -precision 6
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /theremin_tb/reset_n
add wave -noupdate /theremin_tb/clk
add wave -noupdate /theremin_tb/square_freq
add wave -noupdate -format Analog-Step -height 74 -max 0.99993900000000013 -min -0.99993900000000002 /theremin_tb/mixer_out
add wave -noupdate /theremin_tb/cic_pm/integrator_reg
add wave -noupdate /theremin_tb/cic_pm/comb_in_reg
add wave -noupdate /theremin_tb/cic_pm/comb_reg
add wave -noupdate /theremin_tb/cic_pm/count_reg
add wave -noupdate /theremin_tb/audio_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133950 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
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
WaveRestoreZoom {127436 ns} {142348 ns}
