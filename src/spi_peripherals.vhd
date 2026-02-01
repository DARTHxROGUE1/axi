library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_peripheral is
    generic(
        GPIO_WIDTH : integer := 32;
        USE_GPIO: boolean := false;
        ACTIVE_LOW_SS: boolean := false
    );
    port(
        mosi : out std_logic;
        ss : out std_logic;
        ssn : out std_logic;
        sclk: out std_logic;
        miso : in std_logic;
        gpo : out std_logic_vector(GPIO_WIDTH-1 downto 0);
        read_addr: in std_logic_vector(1 downto 0);
        write_addr: in std_logic_vector(1 downto 0);
        write_enable: in std_logic;
        read_enable: in std_logic;
        read_data: out std_logic_vector(31 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        write_strobe: in std_logic_vector(3 downto 0);
        clk : in std_logic;
        resetn : in std_logic
    );
end entity spi_peripheral;

architecture rtl of spi_peripheral is
    signal reg0 : std_logic_vector(31 downto 0);
    signal reg1 : std_logic_vector(31 downto 0);
    signal reg2 : std_logic_vector(31 downto 0);
    signal reg3 : std_logic_vector(31 downto 0); 
    signal spidata_reg, spirxbuf_reg : std_logic_vector(7 downto 0);
    signal sptef, sptef_ack: std_logic;
    signal sprf, sprf_ack, sprf_set: std_logic;
    signal spi_busy: std_logic;
    signal baud_cntr: integer range 0 to 65535;
    type SPI_STATE_TYPE is (ST_IDLE, ST_SS_START, ST_BIT1, ST_BIT2, ST_SS_END, ST_RESTART);
    signal state : SPI_STATE_TYPE;
    signal bit_cntr : integer range 0 to 7;
    signal CPOL : std_logic;
    signal CPHA : std_logic;
    signal LOOPBACK : std_logic;
    signal LSBF: std_logic;
    signal BAUD_DVSR: std_logic_vector(15 downto 0);
    signal miso_sync: std_logic_vector(2 downto 0);
    signal ssn_sig: std_logic;
    signal data_in: std_logic;
    signal baud_clk: std_logic;
    signal spi_sample, spi_shift, spi_data: std_logic;
begin
    CPOL <= reg2(17);
    CPHA <= reg2(16);
    LOOPBACK <= reg2(18);
    LSBF <= reg2(19);
    BAUD_DVSR <= reg2(15 downto 0);
    
    data_in <= miso_sync(0) when LOOPBACK = '0' else spidata_reg(7);
    
    gpo_gen: if USE_GPIO generate
        gpo <= reg3(GPIO_WIDTH-1 downto 0);
    end generate;
    
    gpo_no_gen: if not USE_GPIO generate
        gpo <= (others => '0');
    end generate;
    
    ss_gen: if not ACTIVE_LOW_SS generate
        ss <= not ssn_sig;
        ssn <= '1';
    end generate;
    
    ss_active_low_gen: if ACTIVE_LOW_SS generate
        ss <= '0';
        ssn <= ssn_sig;
    end generate;
    
    process(clk)
    begin
        if rising_edge(clk) then 
            if resetn = '0' then
                reg0 <= (others => '0');
                reg1 <= (others => '0');
                reg2 <= (others => '0');
                reg3 <= (others => '0');
                sptef <= '1';
            else
                if (write_enable = '1') then 
                    case write_addr is
                        when "00" => 
                            if (write_strobe(0) = '1') then
                                reg0(7 downto 0) <= write_data(7 downto 0);
                                sptef <= '0';
                            end if;
                            if (write_strobe(1) = '1') then
                                reg0(15 downto 8) <= (others => '0');
                            end if;
                            if (write_strobe(2) = '1') then
                                reg0(23 downto 16) <= (others => '0');
                            end if;
                            if (write_strobe(3) = '1') then
                                reg0(31 downto 24) <= (others => '0');
                            end if;
                        when "01" => 
                            reg1 <= (others => '0'); 
                        when "10" =>
                            if (write_strobe(0) = '1') then
                                reg2(7 downto 0) <= write_data(7 downto 0);
                            end if;
                            if (write_strobe(1) = '1') then
                                reg2(15 downto 8) <= write_data(15 downto 8);
                            end if;
                            if (write_strobe(2) = '1') then
                                reg2(23 downto 20) <= (others => '0');
                                reg2(19 downto 16) <= write_data(19 downto 16);
                            end if;
                            if (write_strobe(3) = '1') then
                                reg2(31 downto 24) <= (others => '0');
                            end if;
                        when "11" =>
                            if USE_GPIO then
                                for byte_index in 0 to 3 loop
                                    if (write_strobe(byte_index) = '1') then
                                        reg3(byte_index*8+7 downto byte_index*8) <= write_data(byte_index*8+7 downto byte_index*8);
                                    end if;
                                end loop; 
                            else 
                                reg3 <= (others => '0');
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
                
                if sptef_ack = '1' then
                    sptef <= '1';
                end if;
            end if;
        end if;
    end process;

    process(reg0, reg1, reg2, reg3, read_addr, read_enable, spidata_reg, spirxbuf_reg, sptef, sprf)
    begin 
        sprf_ack <= '0';
        read_data <= (others => '0');
        case read_addr is
            when "00" =>
                read_data(7 downto 0) <= spirxbuf_reg;
            when "01" =>
                read_data(0) <= sptef;
                read_data(1) <= sprf;
                read_data(2) <= spi_busy;
                if read_enable = '1' then
                    sprf_ack <= '1';
                end if;
            when "10" =>
                read_data(19 downto 0) <= reg2(19 downto 0);
            when "11" =>
                read_data <= (others => '0');
            when others =>
                read_data <= (others => '0');
        end case;
    end process;

    process(clk)
    begin 
        if (rising_edge(clk)) then
            if (resetn = '0') then
                sprf <= '0';
            else
                if read_enable = '1' then
                    if sprf_ack = '1' then
                        sprf <= '0';
                    end if;  	   
                end if;   
                if sprf_set = '1' then
                    sprf <= '1';
                end if;
            end if;
        end if;
    end process;

    mosi <= spidata_reg(7) when LSBF = '0' else spidata_reg(0);
    
    process(clk)
        variable spi_control: std_logic_vector(1 downto 0);
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                spi_data <= '0';
                spidata_reg <= (others => '0');
            else
                if spi_sample = '1' then
                    spi_data <= data_in;
                end if;

                spi_control := spi_shift & sptef_ack;
                case spi_control is 
                    when "10" =>
                        if LSBF = '0' then 
                            spidata_reg <= spidata_reg(6 downto 0) & spi_data;
                        else
                            spidata_reg <= spi_data & spidata_reg(7 downto 1);
                        end if;
                    when "01" =>
                        spidata_reg <= reg0(7 downto 0);
                    when others => 
                        null;
                end case;
            end if;
        end if;
    end process;

    baud_clk <= '1' when baud_cntr = 0 else '0';
    
    process(clk)
    begin
        if (rising_edge(clk)) then
            miso_sync <= miso & miso_sync(2 downto 1);
            if (resetn = '0') then 
                state <= ST_IDLE;
                baud_cntr <= 0;
                sptef_ack <= '0';
                sclk <= '0';
                sprf_set <= '0';
                ssn_sig <= '1';
                spi_sample <= '0';
                spi_shift <= '0';
                spi_busy <= '0';
                bit_cntr <= 0;
            else 
                if state = ST_IDLE or baud_cntr = 0 then
                    baud_cntr <= to_integer(unsigned(BAUD_DVSR));
                else
                    baud_cntr <= baud_cntr - 1;
                end if;
                
                sptef_ack <= '0';
                sclk <= CPOL;
                sprf_set <= '0';
                ssn_sig <= '0';
                spi_sample <= '0';
                spi_shift <= '0';
                spi_busy <= '1';
                
                case state is
                    when ST_IDLE => 
                        ssn_sig <= '1';
                        spi_busy <= '0'; 
                        if sptef = '0' then 
                            state <= ST_SS_START;
                            sptef_ack <= '1';
                        end if;
                    when ST_SS_START => 
                        if baud_clk = '1' then 
                            state <= ST_BIT1;
                            bit_cntr <= 0;
                            if CPHA = '0' then
                                spi_sample <= '1';
                            end if;
                        end if;
                    when ST_BIT1 => 
                        sclk <= not CPOL; 
                        if baud_clk = '1' then 
                            state <= ST_BIT2;
                            if CPHA = '0' then
                                spi_shift <= '1';
                            else
                                spi_sample <= '1';
                            end if;
                        end if;
                    when ST_BIT2 =>  
                        sclk <= CPOL; 
                        if baud_clk = '1' then
                            if CPHA = '1' then
                                spi_shift <= '1';
                            else
                                spi_sample <= '1';
                            end if; 
                            if bit_cntr = 7 then
                                state <= ST_SS_END;
                            else
                                bit_cntr <= bit_cntr + 1;
                                state <= ST_BIT1;
                            end if;
                        end if;
                    when ST_SS_END =>
                        if baud_clk = '1' then
                            if CPHA = '1' then
                                spi_shift <= '1';
                            end if;
                            state <= ST_RESTART;
                        end if;
                    when ST_RESTART => 
                        sprf_set <= '1';
                        spirxbuf_reg <= spidata_reg;
                        if sptef = '0' then 
                            state <= ST_SS_START;
                            sptef_ack <= '1';
                        else
                            state <= ST_IDLE;
                        end if;
                    when others => 
                        state <= ST_IDLE;              
                end case;
            end if;
        end if;
    end process;

end architecture rtl;