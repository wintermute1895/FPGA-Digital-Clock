onerror {quit -f}
vlib work
vlog -work work DigitalClock.vo
vlog -work work DigitalClock.vt
vsim -novopt -c -t 1ps -L cycloneiii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.DigitalClock_vlg_vec_tst
vcd file -direction DigitalClock.msim.vcd
vcd add -internal DigitalClock_vlg_vec_tst/*
vcd add -internal DigitalClock_vlg_vec_tst/i1/*
add wave /*
run -all
