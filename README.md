This project implements an AXI4-Lite SPI controller on the programmable logic (PL) of the Kria KV260 FPGA platform.
The FPGA behaves as an external memory-mapped AXI slave peripheral, controlled by an external AXI master (processor or SoC).
The design exposes a register interface over AXI for configuring and operating an SPI master connected to external SPI devices.

I would recommmend a custom .xdc file based on your fpga and do read the pin mappings

# architecture
   
     External Processor / SoC (AXI Master)
            |
     Physical AXI Bus (board traces)
            │
        FPGA device
            │
      axi_spi_top (AXI Slave + SPI Controller) 
            │
        SPI pins
            │
     External SPI Device (Display / Peripheral)


<img width="1536" height="1024" alt="ChatGPT Image Feb 18, 2026, 12_28_23 AM" src="https://github.com/user-attachments/assets/b0cec811-462c-4466-983e-7118f4b6a000" />


# RTL

<img width="1616" height="481" alt="Screenshot 2026-02-17 231149" src="https://github.com/user-attachments/assets/f6d7f4d5-f9b7-4547-aa67-83ae100f1869" />


# Synthesis

<img width="1532" height="848" alt="Screenshot 2026-02-17 231305" src="https://github.com/user-attachments/assets/8a62a68c-9ff6-42cc-8c77-cf2ce2b04f08" />
<img width="1600" height="812" alt="Screenshot 2026-02-17 231602" src="https://github.com/user-attachments/assets/4c5d5f98-5563-4b01-a584-b154bcd1de1a" />
<img width="1609" height="835" alt="Screenshot 2026-02-17 231552" src="https://github.com/user-attachments/assets/1741728f-a057-417d-bbac-d9add00ae933" />

# Implimentation 

<img width="995" height="537" alt="Screenshot 2026-02-17 231702" src="https://github.com/user-attachments/assets/d682f19d-2638-454e-af8f-50a65376f833" />
<img width="902" height="785" alt="Screenshot 2026-02-17 232204" src="https://github.com/user-attachments/assets/54ff9282-fed9-4b9e-a08c-220d0eda4359" />
<img width="1117" height="728" alt="Screenshot 2026-02-17 232041" src="https://github.com/user-attachments/assets/61c7880b-240a-4b50-96a7-312a8d108ed2" />
<img width="897" height="690" alt="Screenshot 2026-02-17 232003" src="https://github.com/user-attachments/assets/5f49fcc3-f952-41ea-9d4d-b61b73beb9df" />
