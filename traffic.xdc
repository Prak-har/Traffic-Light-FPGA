## =========================
## CLOCK & RESET
## =========================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## =========================
## PUSH BUTTONS
## =========================
set_property PACKAGE_PIN T18 [get_ports btnU] ;# BTNU
set_property PACKAGE_PIN W19 [get_ports btnL] ;# BTNL
set_property PACKAGE_PIN T17 [get_ports btnR] ;# BTNR
set_property PACKAGE_PIN U17 [get_ports btnD] ;# BTND
set_property IOSTANDARD LVCMOS33 [get_ports {btnU btnL btnR btnD}]

## =========================
## TRAFFIC LIGHT OUTPUTS
## =========================
set_property PACKAGE_PIN J1 [get_ports {light_M1[0]}]
set_property PACKAGE_PIN L2 [get_ports {light_M1[1]}]
set_property PACKAGE_PIN J2 [get_ports {light_M1[2]}]

set_property PACKAGE_PIN G2 [get_ports {light_MT[0]}]
set_property PACKAGE_PIN H1 [get_ports {light_MT[1]}]
set_property PACKAGE_PIN K2 [get_ports {light_MT[2]}]

set_property PACKAGE_PIN A14 [get_ports {light_M2[0]}]
set_property PACKAGE_PIN A16 [get_ports {light_M2[1]}]
set_property PACKAGE_PIN B15 [get_ports {light_M2[2]}]

set_property PACKAGE_PIN K17 [get_ports {light_S[0]}]
set_property PACKAGE_PIN M18 [get_ports {light_S[1]}]
set_property PACKAGE_PIN N17 [get_ports {light_S[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {light_M1[*] light_M2[*] light_MT[*] light_S[*]}]

## =========================
## 7-SEGMENT DISPLAY
## =========================
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

## Clock constraint (100 MHz)
create_clock -period 10.0 -name sys_clk -waveform {0 5} [get_ports clk]
