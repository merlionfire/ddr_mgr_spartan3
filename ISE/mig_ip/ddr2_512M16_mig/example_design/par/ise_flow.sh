./rem_files.sh



echo Synthesis Tool: XST

mkdir "../synth/__projnav" > ise_flow_results.txt
mkdir "../synth/xst" >> ise_flow_results.txt
mkdir "../synth/xst/work" >> ise_flow_results.txt

xst -ifn ise_run.txt -ofn mem_interface_top.syr -intstyle ise >> ise_flow_results.txt
ngdbuild -intstyle ise -dd ../synth/_ngo -uc ddr2_512M16_mig.ucf -p xc3s700anfgg484-4 ddr2_512M16_mig.ngc ddr2_512M16_mig.ngd >> ise_flow_results.txt

map -intstyle ise -detail -cm speed -pr off -c 100 -o ddr2_512M16_mig_map.ncd ddr2_512M16_mig.ngd ddr2_512M16_mig.pcf >> ise_flow_results.txt
par -w -intstyle ise -ol std -t 1 ddr2_512M16_mig_map.ncd ddr2_512M16_mig.ncd ddr2_512M16_mig.pcf >> ise_flow_results.txt
trce -e 100 ddr2_512M16_mig.ncd ddr2_512M16_mig.pcf >> ise_flow_results.txt
bitgen -intstyle ise -f mem_interface_top.ut ddr2_512M16_mig.ncd >> ise_flow_results.txt

echo done!
