-- optimized using chatgpt 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_spi_top is
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic;

    saxi_awaddr   : in  std_logic_vector(31 downto 0);
    saxi_awprot   : in  std_logic_vector(2 downto 0);
    saxi_awvalid  : in  std_logic;
    saxi_awready  : out std_logic;

    saxi_wdata    : in  std_logic_vector(31 downto 0);
    saxi_wstrb    : in  std_logic_vector(3 downto 0);
    saxi_wvalid   : in  std_logic;
    saxi_wready   : out std_logic;

    saxi_bresp    : out std_logic_vector(1 downto 0);
    saxi_bvalid   : out std_logic;
    saxi_bready   : in  std_logic;

    saxi_araddr   : in  std_logic_vector(31 downto 0);
    saxi_arprot   : in  std_logic_vector(2 downto 0);
    saxi_arvalid  : in  std_logic;
    saxi_arready  : out std_logic;

    saxi_rdata    : out std_logic_vector(31 downto 0);
    saxi_rresp    : out std_logic_vector(1 downto 0);
    saxi_rvalid   : out std_logic;
    saxi_rready   : in  std_logic;

    spi_mosi      : out std_logic;
    spi_miso      : in  std_logic;
    spi_sclk      : out std_logic;
    spi_ss        : out std_logic;
    spi_ssn       : out std_logic;

    gpo           : out std_logic_vector(31 downto 0)
  );
end entity axi_spi_top;

architecture rtl of axi_spi_top is
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
      mosi          => spi_mosi,
      miso          => spi_miso,
      sclk          => spi_sclk,
      ss            => spi_ss,
      ssn           => spi_ssn,
      gpo           => gpo,

      S_AXI_ACLK    => aclk,
      saxi_aresetn  => aresetn,

      saxi_awaddr   => saxi_awaddr,
      saxi_awprot   => saxi_awprot,
      saxi_awvalid  => saxi_awvalid,
      saxi_awready  => saxi_awready,

      saxi_wdata    => saxi_wdata,
      saxi_wstrb    => saxi_wstrb,
      saxi_wvalid   => saxi_wvalid,
      saxi_wready   => saxi_wready,

      saxi_bresp    => saxi_bresp,
      saxi_bvalid   => saxi_bvalid,
      saxi_bready   => saxi_bready,

      saxi_araddr   => saxi_araddr,
      saxi_arprot   => saxi_arprot,
      saxi_arvalid  => saxi_arvalid,
      saxi_arready  => saxi_arready,

      saxi_rdata    => saxi_rdata,
      saxi_rresp    => saxi_rresp,
      saxi_rvalid   => saxi_rvalid,
      saxi_rready   => saxi_rready
    );

end architecture rtl;
