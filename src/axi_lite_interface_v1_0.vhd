library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--debugged using claude ai
entity interface is
  generic(
    DATA_BUS_64_BITS : integer range 0 to 1 := 0;
    ADDR_WIDTH : integer range 1 to 12 := 2;
    USE_WRITE_STROBES : boolean := false;
    SUBORDINATE_SYNCHRONOUS_READ_PORT: boolean := true
  );
  port (
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector(31 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector((32*(DATA_BUS_64_BITS+1))-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((4*(1+DATA_BUS_64_BITS))-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector(31 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector((32*(DATA_BUS_64_BITS+1))-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    
    read_address  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    write_address : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    read_enable   : out std_logic;
    write_enable  : out std_logic;
    write_strobe  : out std_logic_vector((4*(1+DATA_BUS_64_BITS))-1 downto 0);
    read_data     : in  std_logic_vector((32*(DATA_BUS_64_BITS + 1)) -1 downto 0);
    write_data    : out std_logic_vector((32*(1+DATA_BUS_64_BITS)) -1 downto 0);
    clk           : out std_logic;
    resetn        : out std_logic
  );
end entity interface;

architecture arch_imp of interface is
  signal awready : std_logic;
  signal wready  : std_logic;
  signal bresp   : std_logic_vector(1 downto 0);
  signal bvalid  : std_logic;
  signal arready : std_logic;
  signal rdata   : std_logic_vector((32*(1+DATA_BUS_64_BITS)) -1 downto 0);
  signal rresp   : std_logic_vector(1 downto 0);
  signal rvalid  : std_logic;
  
  constant REG_ADDR_lsb : integer := 2*(1+DATA_BUS_64_BITS);
  constant REG_ADDR_msb : integer := ADDR_WIDTH + REG_ADDR_lsb -1;
  
  signal read_addr_stall_reg   : std_logic_vector(REG_ADDR_msb downto REG_ADDR_lsb);
  signal write_addr_stall_reg  : std_logic_vector(REG_ADDR_msb downto REG_ADDR_lsb);
  signal write_data_stall_reg  : std_logic_vector(32*(1+DATA_BUS_64_BITS) -1 downto 0);
  signal write_strobe_stall_reg: std_logic_vector((4*(1+DATA_BUS_64_BITS)) -1 downto 0);
  
  signal sig_read_enable : std_logic;
  
  alias local_read_addr  : std_logic_vector(REG_ADDR_msb downto REG_ADDR_lsb) is S_AXI_ARADDR(REG_ADDR_msb downto REG_ADDR_lsb);
  alias local_write_addr : std_logic_vector(REG_ADDR_msb downto REG_ADDR_lsb) is S_AXI_AWADDR(REG_ADDR_msb downto REG_ADDR_lsb);

begin
  -- Output assignments
  S_AXI_AWREADY <= awready;
  S_AXI_WREADY  <= wready;
  S_AXI_BRESP   <= bresp;
  S_AXI_BVALID  <= bvalid;
  S_AXI_ARREADY <= arready;
  S_AXI_RDATA   <= rdata;
  S_AXI_RRESP   <= rresp;
  S_AXI_RVALID  <= rvalid;
  
  read_enable <= sig_read_enable;
  clk         <= S_AXI_ACLK;
  resetn      <= S_AXI_ARESETN;
  
  bresp <= (others => '0');
  rresp <= (others => '0');
  
  -- Read address channel
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        arready <= '1';
      elsif arready = '0' and S_AXI_ARVALID = '1' then
        arready <= '1';
      elsif rvalid='1' AND S_AXI_RREADY='0' and S_AXI_ARVALID='1' and arready='1' then
        read_addr_stall_reg <= local_read_addr;
        arready <= '0';
      end if;
    end if;
  end process;
  
  process(arready, S_AXI_ARVALID, S_AXI_RREADY, rvalid, read_addr_stall_reg, local_read_addr)
  begin
    if arready='0' and S_AXI_RREADY='1' and rvalid='1' then
      sig_read_enable <= '1';
      read_address <= read_addr_stall_reg;
    elsif arready='1' and S_AXI_ARVALID='1' and (S_AXI_RREADY='1' OR rvalid='0') then
      
      sig_read_enable <= '1';
      read_address <= local_read_addr;
    else
      sig_read_enable <= '0';
      read_address <= (others => '-');
    end if;
  end process;
  
  gen_read_port: if (SUBORDINATE_SYNCHRONOUS_READ_PORT) generate
    rdata <= read_data;
  end generate;
  
  gen_read_port_else: if (NOT SUBORDINATE_SYNCHRONOUS_READ_PORT) generate
    process(S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          rdata <= (others => '0');
        elsif sig_read_enable='1' then
          rdata <= read_data;
        end if;
      end if;
    end process;
  end generate;
  
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        rvalid <= '0';
      else
        if rvalid='1' and S_AXI_RREADY='1' then
          rvalid <= '0';
        end if;
        
        if arready='0' and S_AXI_RREADY='1' and rvalid='1' then
          rvalid <= '1';
        elsif arready='1' and S_AXI_ARVALID='1' and (S_AXI_RREADY='1' OR rvalid='0') then
          rvalid <= '1';
        end if;
      end if;
    end if;
  end process;
  
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        awready <= '1';
      elsif awready='0' and (S_AXI_WVALID='1' OR wready='0') and S_AXI_BREADY='1' then
        awready <= '1';
      elsif S_AXI_AWVALID='1' and not (S_AXI_WVALID='1' and S_AXI_BREADY='1') then
        write_addr_stall_reg <= local_write_addr;
        awready <= '0';
      end if;
    end if;
  end process;
  
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        wready <= '1';
      elsif wready='0' and (S_AXI_AWVALID='1' OR awready='0') and S_AXI_BREADY='1' then
        wready <= '1';
      elsif S_AXI_WVALID='1' and not (S_AXI_AWVALID='1' and S_AXI_BREADY='1') then
        write_data_stall_reg <= S_AXI_WDATA;
        if USE_WRITE_STROBES then
          write_strobe_stall_reg <= S_AXI_WSTRB;
        end if;
        wready <= '0';
      end if;
    end if;
  end process;
  
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        bvalid <= '0';
      else
        if bvalid='1' and S_AXI_BREADY='1' then
          bvalid <= '0';
        end if;
        
        if awready='0' and wready='0' and S_AXI_BREADY='1' then
          bvalid <= '1';
        elsif awready='0' and S_AXI_WVALID='1' and S_AXI_BREADY='1' then
          bvalid <= '1';
        elsif S_AXI_AWVALID='1' and wready='0' and S_AXI_BREADY='1' then
          bvalid <= '1';
        elsif S_AXI_AWVALID='1' and S_AXI_WVALID='1' and S_AXI_BREADY='1' then
          bvalid <= '1';
        end if;
      end if;
    end if;
  end process;
  
  
  process(awready, wready, S_AXI_BREADY, write_addr_stall_reg, write_data_stall_reg, 
          write_strobe_stall_reg, S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WVALID, 
          S_AXI_AWVALID, local_write_addr)
  begin
    
    write_enable  <= '0';
    write_address <= (others => '-');
    write_data    <= (others => '-');
    write_strobe  <= (others => '-');
    
    
    if awready='0' and wready='0' and S_AXI_BREADY='1' then
      write_address <= write_addr_stall_reg;
      write_data    <= write_data_stall_reg;
      write_strobe  <= write_strobe_stall_reg;
      write_enable  <= '1';
    elsif awready='0' and S_AXI_WVALID='1' and S_AXI_BREADY='1' then
      write_address <= write_addr_stall_reg;
      write_data    <= S_AXI_WDATA;
      write_strobe  <= S_AXI_WSTRB;
      write_enable  <= '1';
    elsif S_AXI_AWVALID='1' and wready='0' and S_AXI_BREADY='1' then
      write_address <= local_write_addr;
      write_data    <= write_data_stall_reg;
      write_strobe  <= write_strobe_stall_reg;
      write_enable  <= '1';
    elsif S_AXI_AWVALID='1' and S_AXI_WVALID='1' and S_AXI_BREADY='1' then
      write_address <= local_write_addr;
      write_data    <= S_AXI_WDATA;
      write_strobe  <= S_AXI_WSTRB;
      write_enable  <= '1';
    end if;
  end process;

end architecture arch_imp;