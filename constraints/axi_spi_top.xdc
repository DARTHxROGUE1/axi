########################################
# AXI CLOCK FROM EXTERNAL MASTER
########################################
set_property PACKAGE_PIN <PIN_ACLK> [get_ports aclk]
set_property IOSTANDARD LVCMOS33 [get_ports aclk]
create_clock -period 10.000 [get_ports aclk]

########################################
# AXI RESET
########################################
set_property PACKAGE_PIN <PIN_RESET> [get_ports aresetn]
set_property IOSTANDARD LVCMOS33 [get_ports aresetn]
set_property PULLUP true [get_ports aresetn]

########################################
# SPI INTERFACE
########################################
set_property PACKAGE_PIN <PIN_SPI_SCLK> [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]

set_property PACKAGE_PIN <PIN_SPI_MOSI> [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]

set_property PACKAGE_PIN <PIN_SPI_MISO> [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]

set_property PACKAGE_PIN <PIN_SPI_SS> [get_ports spi_ss]
set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]

set_property PACKAGE_PIN <PIN_SPI_SSN> [get_ports spi_ssn]
set_property IOSTANDARD LVCMOS33 [get_ports spi_ssn]

########################################
# GPIO 
########################################
set_property PACKAGE_PIN <PIN_GPO0> [get_ports {gpo[0]}]
set_property PACKAGE_PIN <PIN_GPO1> [get_ports {gpo[1]}]
set_property PACKAGE_PIN <PIN_GPO2> [get_ports {gpo[2]}]
set_property PACKAGE_PIN <PIN_GPO3> [get_ports {gpo[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpo[*]}]
