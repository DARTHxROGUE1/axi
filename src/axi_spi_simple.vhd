library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity axi_spi_simple is
generic (
ACTIVE_LOW_SS : boolean := true;
GPIO_WIDTH: integer := 32;
USE_GPIO: boolean := false;
SAXI_DATA_WIDTH : integer := 32;
SAXI_ADDR_WIDTH : integer := 2
    );
    port (
    mosi: out std_logic;
    ss: out std_logic;
    ssn: out std_logic;
    sclk: out std_logic;
    miso: in std_logic;
    gpo: out std_logic_vector(GPIO_WIDTH-1 downto 0);
        
    S_AXI_ACLK : in std_logic;
        
    saxi_aresetn : in std_logic;
    saxi_awaddr : in std_logic_vector(31 downto 0);
    saxi_awprot : in std_logic_vector(2 downto 0);
        saxi_awvalid : in std_logic;
        saxi_awready : out std_logic;
    saxi_wdata : in std_logic_vector(SAXI_DATA_WIDTH-1 downto 0);
    saxi_wstrb : in std_logic_vector((SAXI_DATA_WIDTH/8)-1 downto 0);
        saxi_wvalid : in std_logic;
        saxi_wready : out std_logic;
    saxi_bresp : out std_logic_vector(1 downto 0);
        saxi_bvalid : out std_logic;
        saxi_bready : in std_logic;
    saxi_araddr : in std_logic_vector(31 downto 0);
    saxi_arprot : in std_logic_vector(2 downto 0);
        saxi_arvalid : in std_logic;
        saxi_arready : out std_logic;
    saxi_rdata : out std_logic_vector(SAXI_DATA_WIDTH-1 downto 0);
    saxi_rresp : out std_logic_vector(1 downto 0);
        saxi_rvalid : out std_logic;
        saxi_rready : in std_logic
    );
end axi_spi_simple;

architecture rtl0 of axi_spi_simple is
    component axi4_lite_interface_v1_0 is
        generic (
            DATA_BUS_IS_64_BITS: integer range 0 to 1 := 0;
            ADDR_WIDTH : integer range 1 to 12 := 2;
            USE_WRITE_STROBES : boolean := false;
            SUBORDINATE_SYNCHRONOUS_READ_PORT: boolean := true
        );
        port (
            S_AXI_ACLK : in std_logic;
            S_AXI_ARESETN : in std_logic;
            S_AXI_AWADDR : in std_logic_vector(31 downto 0);
            S_AXI_AWPROT : in std_logic_vector(2 downto 0);
            S_AXI_AWVALID : in std_logic;
            S_AXI_AWREADY : out std_logic;
            S_AXI_WDATA : in std_logic_vector(32*(1+DATA_BUS_IS_64_BITS) -1 downto 0);
            S_AXI_WSTRB : in std_logic_vector((4*(1+DATA_BUS_IS_64_BITS))-1 downto 0);
            S_AXI_WVALID : in std_logic;
            S_AXI_WREADY : out std_logic;
            S_AXI_BRESP : out std_logic_vector(1 downto 0);
            S_AXI_BVALID : out std_logic;
            S_AXI_BREADY : in std_logic;
            S_AXI_ARADDR : in std_logic_vector(31 downto 0);
            S_AXI_ARPROT : in std_logic_vector(2 downto 0);
            S_AXI_ARVALID : in std_logic;
            S_AXI_ARREADY : out std_logic;
            S_AXI_RDATA : out std_logic_vector(31 downto 0);
            S_AXI_RRESP : out std_logic_vector(1 downto 0);
            S_AXI_RVALID : out std_logic;
            S_AXI_RREADY : in std_logic;
            read_address: out std_logic_vector(ADDR_WIDTH-1 downto 0);
            write_address: out std_logic_vector(ADDR_WIDTH-1 downto 0);
            read_enable: out std_logic;
            write_enable: out std_logic;
            write_strobe: out std_logic_vector((4*(1+DATA_BUS_IS_64_BITS))-1 downto 0);
            read_data: in std_logic_vector(32*(1+DATA_BUS_IS_64_BITS) -1 downto 0);
            write_data: out std_logic_vector(32*(1+DATA_BUS_IS_64_BITS) -1 downto 0);
            clk: out std_logic;
            resetn: out std_logic
        );
    end component;

    component spi_peripheral is
        generic (
            GPIO_WIDTH: integer := 32;
            USE_GPIO: boolean := false;
            ACTIVE_LOW_SS: boolean := false
        );
    port (
        mosi: out std_logic;
        ss: out std_logic;
        ssn: out std_logic;
        sclk: out std_logic;
        miso: in std_logic;
        gpo: out std_logic_vector(GPIO_WIDTH-1 downto 0);
        
        write_strobe: in std_logic_vector(3 downto 0);
        read_addr: in std_logic_vector(1 downto 0);
        write_addr: in std_logic_vector(1 downto 0);
        write_enable: in std_logic;
        read_enable: in std_logic;
        read_data: out std_logic_vector(31 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        
        clk: in std_logic;
        resetn: in std_logic
        );
    end component spi_peripheral;
   
    signal read_address: std_logic_vector(1 downto 0);
    signal write_address: std_logic_vector(1 downto 0);
    signal read_enable: std_logic;
    signal write_enable: std_logic;
    signal read_data: std_logic_vector(31 downto 0);
    signal write_data: std_logic_vector(31 downto 0);
    signal write_strobe: std_logic_vector(3 downto 0);
    signal clk: std_logic;
    signal resetn: std_logic;
    constant is_64b_data_bus: integer := (SAXI_DATA_WIDTH)/32-1; 
begin

    U0: spi_peripheral
    generic map(
        USE_GPIO => USE_GPIO,
        GPIO_WIDTH => GPIO_WIDTH,
        ACTIVE_LOW_SS => ACTIVE_LOW_SS
    )
    port map(
        mosi => mosi,
        miso => miso,
        ssn => ssn,
        ss => ss,
        sclk => sclk,
        gpo => gpo,
        read_addr => read_address,
        write_addr => write_address,
        read_data => read_data,
        write_data => write_data,
        write_enable => write_enable,
        read_enable => read_enable,
        write_strobe => write_strobe,
        clk => clk,
        resetn => resetn    
    );

    U1: axi4_lite_interface_v1_0 
    generic map(
        DATA_BUS_IS_64_BITS => is_64b_data_bus,
        ADDR_WIDTH => 2,
        USE_WRITE_STROBES => true,
        SUBORDINATE_SYNCHRONOUS_READ_PORT => true
    )
port map(
S_AXI_ACLK => S_AXI_ACLK,
S_AXI_ARESETN => SAXI_ARESETN,
S_AXI_AWADDR => SAXI_AWADDR,
S_AXI_AWPROT => SAXI_AWPROT,
S_AXI_AWVALID => SAXI_AWVALID,
S_AXI_AWREADY => SAXI_AWREADY,

S_AXI_WDATA => SAXI_WDATA,
S_AXI_WSTRB => SAXI_WSTRB,
S_AXI_WVALID => SAXI_WVALID,
S_AXI_WREADY => SAXI_WREADY,

S_AXI_BRESP => SAXI_BRESP,
S_AXI_BVALID => SAXI_BVALID,
S_AXI_BREADY => SAXI_BREADY,

S_AXI_ARADDR => SAXI_ARADDR,
S_AXI_ARPROT => SAXI_ARPROT,
S_AXI_ARVALID => SAXI_ARVALID,
S_AXI_ARREADY => SAXI_ARREADY,

S_AXI_RDATA => SAXI_RDATA,
S_AXI_RRESP => SAXI_RRESP,
S_AXI_RVALID => SAXI_RVALID,
S_AXI_RREADY => SAXI_RREADY,


read_address => read_address,
read_enable => read_enable,
write_address => write_address,
write_enable => write_enable,
read_data => read_data,
    write_data => write_data,
    write_strobe => write_strobe,
        clk => clk,
        resetn => resetn
    );

end rtl0;
