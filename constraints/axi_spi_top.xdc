set_property PACKAGE_PIN L19 [get_ports aclk]
set_property IOSTANDARD LVCMOS33 [get_ports aclk]
create_clock -period 10.000 -name axi_clk -waveform {0 5} [get_ports aclk]

set_property PACKAGE_PIN M19 [get_ports aresetn]
set_property IOSTANDARD LVCMOS33 [get_ports aresetn]
set_property PULLUP true [get_ports aresetn]

set_property PACKAGE_PIN W18 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]

set_property PACKAGE_PIN W19 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]

set_property PACKAGE_PIN V18 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]

set_property PACKAGE_PIN V19 [get_ports spi_ss]
set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]

set_property PACKAGE_PIN U19 [get_ports spi_ssn]
set_property IOSTANDARD LVCMOS33 [get_ports spi_ssn]

set_property PACKAGE_PIN U17 [get_ports {gpo[0]}]
set_property PACKAGE_PIN U18 [get_ports {gpo[1]}]
set_property PACKAGE_PIN T17 [get_ports {gpo[2]}]
set_property PACKAGE_PIN T18 [get_ports {gpo[3]}]
set_property PACKAGE_PIN R17 [get_ports {gpo[4]}]
set_property PACKAGE_PIN R18 [get_ports {gpo[5]}]
set_property PACKAGE_PIN P17 [get_ports {gpo[6]}]
set_property PACKAGE_PIN P18 [get_ports {gpo[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpo[*]}]
