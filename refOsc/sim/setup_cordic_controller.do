onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
radix define fixed#28#decimal#signed -fixed -fraction 28 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /cordic_control_tb/clk
add wave -noupdate /cordic_control_tb/reset_n
add wave -noupdate -format Analog-Step -height 74 -min -342.0 /cordic_control_tb/phi
add wave -noupdate -format Analog-Step -height 74 -max 3.0000000000000844 -min -878.0 /cordic_control_tb/sine
add wave -noupdate /cordic_control_tb/control_pm/sig_Freq
add wave -noupdate /cordic_control_tb/control_pm/clk_Period
add wave -noupdate /cordic_control_tb/control_pm/invert
add wave -noupdate /cordic_control_tb/control_pm/sign_inv
add wave -noupdate /cordic_control_tb/control_pm/p_cmb_stepcalc/sig_Freq_shifted
add wave -noupdate /cordic_control_tb/control_pm/phi_step
add wave -noupdate /cordic_control_tb/control_pm/phi_noninv_cmb
add wave -noupdate /cordic_control_tb/control_pm/phi_noninv_reg
add wave -noupdate /cordic_control_tb/control_pm/p_cmb_phicalc/phi_tmp1
add wave -noupdate /cordic_control_tb/control_pm/p_cmb_phicalc/phi_tmp2
add wave -noupdate /cordic_control_tb/verify_pm/count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
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
WaveRestoreZoom {0 ns} {680 ns}
