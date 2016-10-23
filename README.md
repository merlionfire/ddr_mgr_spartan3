# ddr_mgr_spartan3
Simple ddr manager working with MIG, which is expected to work on spartan 3A starter kit

Remark:
   Find that there exists a lot data errors during read operation when MIG works on 133Mhz, which is based 
   on CLK_AUX of the starter board. 
   But when MIG clock is decreased to 100Mhz ( 2X CLK_50M on the board ), no any read errors occur. 
