# cdce62005
FPGA interface to work with texas cdce62005 clock synthesizer.
Include: vhdl wrapper, isim testbench and register map to easy reconfigurate synthesizer as you need.
Default settings is: 
  1st channel - off; 
  2nd channel - off; 
  3rd channel - 180 MHz (LVDS); 
  4th channel - 180 MHz (LVDS); 
  5th channel - 90 MHz (LVDS).
  ...
I use it for generate clock for GTX Transceivers.
