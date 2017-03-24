# ddr_mgr_spartan3
Simple ddr manager working with MIG, which is expected to work on spartan 3A starter kit

Remark:
   Found that for MIG, there are some net paths from IOs to read_in FIFO which violate STA at 133MHz and higher.     
   With the help of FPGA editor, adjust some nets and add more contraints. 
   The changed MIG has been tested to be working on 133MHz.   
