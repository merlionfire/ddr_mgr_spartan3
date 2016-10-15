
The design files are located at
/home/cct/FPGA_Project/fractal-fpga/ISE/mig_ip:

   - ddr2_512M16_mig.veo:
        veo template file containing code that can be used as a model
        for instantiating a CORE Generator module in a HDL design.

   - ddr2_512M16_mig.xco:
       CORE Generator input file containing the parameters used to
       regenerate a core.

   - ddr2_512M16_mig_flist.txt:
        Text file listing all of the output files produced when a customized
        core was generated in the CORE Generator.

   - ddr2_512M16_mig_readme.txt:
        Text file indicating the files generated and how they are used.

   - ddr2_512M16_mig_xmdf.tcl:
        ISE Project Navigator interface file. ISE uses this file to determine
        how the files output by CORE Generator for the core can be integrated
        into your ISE project.

   - ddr2_512M16_mig directory.

In the ddr2_512M16_mig directory, three folders are created:
   - docs:
        This folder contains XAPP links, design timing analysis spread
        sheets and MIG user guide.

   - example_design:
        This folder includes the design with synthesizable test bench.

   - user_design:
        This folder includes the design without test bench modules.

The example_design and user_design folders contain several other folders
and files. All these output folders are discussed in more detail in
MIG user guide (UG086) located in docs folder.
    