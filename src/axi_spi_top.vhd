library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_spi_top is
  port (
    -- physical FPGA pins
    aclk     : in  std_logic;
    aresetn  : in  std_logic;

    spi_mosi : out std_logic;
    spi_miso : in  std_logic;
    spi_sclk : out std_logic;
    spi_ss   : out std_logic;
    spi_ssn  : out std_logic;

    gpo      : out std_logic_vector(31 downto 0)
  );
end entity axi_spi_top;

architecture rtl of axi_spi_top is

  signal saxi_awaddr  : std_logic_vector(31 downto 0) := (others => '0');
  signal saxi_awprot  : std_logic_vector(2 downto 0)  := (others => '0');
  signal saxi_awvalid : std_logic := '0';
  signal saxi_awready : std_logic;

  signal saxi_wdata   : std_logic_vector(31 downto 0) := (others => '0');
  signal saxi_wstrb   : std_logic_vector(3 downto 0)  := (others => '0');
  signal saxi_wvalid  : std_logic := '0';
  signal saxi_wready  : std_logic;

  signal saxi_bresp   : std_logic_vector(1 downto 0);
  signal saxi_bvalid  : std_logic;
  signal saxi_bready  : std_logic := '1';

  signal saxi_araddr  : std_logic_vector(31 downto 0) := (others => '0');
  signal saxi_arprot  : std_logic_vector(2 downto 0)  := (others => '0');
  signal saxi_arvalid : std_logic := '0';
  signal saxi_arready : std_logic;

  signal saxi_rdata   : std_logic_vector(31 downto 0);
  signal saxi_rresp   : std_logic_vector(1 downto 0);
  signal saxi_rvalid  : std_logic;
  signal saxi_rready  : std_logic := '1';

begin


  u_axi_spi_simple : entity work.axi_spi_simple
    generic map (
      ACTIVE_LOW_SS   => true,
      GPIO_WIDTH      => 32,
      USE_GPIO        => false,
      SAXI_DATA_WIDTH => 32,
      SAXI_ADDR_WIDTH => 2
    )
    port map (
    
      mosi => spi_mosi,
      miso => spi_miso,
      sclk => spi_sclk,
      ss   => spi_ss,
      ssn  => spi_ssn,
      gpo  => gpo,

 
      S_AXI_ACLK   => aclk,
      saxi_aresetn => aresetn,

      -- internal AXI bus
      saxi_awaddr  => saxi_awaddr,
      saxi_awprot  => saxi_awprot,
      saxi_awvalid => saxi_awvalid,
      saxi_awready => saxi_awready,

      saxi_wdata   => saxi_wdata,
      saxi_wstrb   => saxi_wstrb,
      saxi_wvalid  => saxi_wvalid,
      saxi_wready  => saxi_wready,

      saxi_bresp   => saxi_bresp,
      saxi_bvalid  => saxi_bvalid,
      saxi_bready  => saxi_bready,

      saxi_araddr  => saxi_araddr,
      saxi_arprot  => saxi_arprot,
      saxi_arvalid => saxi_arvalid,
      saxi_arready => saxi_arready,

      saxi_rdata   => saxi_rdata,
      saxi_rresp   => saxi_rresp,
      saxi_rvalid  => saxi_rvalid,
      saxi_rready  => saxi_rready
    );

end architecture rtl;
