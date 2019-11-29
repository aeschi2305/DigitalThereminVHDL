onerror {resume}
radix define fixed#15#decimal#signed -fixed -fraction 15 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /cic_tb/mixer_out
add wave -noupdate /cic_tb/verify_pm/p_read/v_data_read
add wave -noupdate -radix binary /cic_tb/audio_out
add wave -noupdate -radix binary /cic_tb/verify_pm/p_write/v_data_write
add wave -noupdate /cic_tb/cic_pm/integrator_reg
add wave -noupdate /cic_tb/cic_pm/comb_in_reg
add wave -noupdate -radix decimal /cic_tb/cic_pm/count_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2518416 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 243
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
WaveRestoreZoom {2519890 ns} {2520050 ns}
