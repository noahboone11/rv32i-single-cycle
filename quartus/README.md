Quartus project setup

Use this folder as the Quartus project directory.

Recommended file layout:
- add all VHDL source files from `../rtl`
- keep testbenches in `../tb` out of the Quartus project
- keep the instruction memory file in `../mem/imem.mif`

Important note for instruction memory:
- `rtl/imem.vhd` references `../mem/imem.mif`
- this path is intended to work when the `.qpf/.qsf` live in this `quartus/` folder

Suggested source files to add:
- `../rtl/adder.vhd`
- `../rtl/alu.vhd`
- `../rtl/alu_decoder.vhd`
- `../rtl/control_unit.vhd`
- `../rtl/datapath.vhd`
- `../rtl/dff_r.vhd`
- `../rtl/dmem.vhd`
- `../rtl/extend_unit.vhd`
- `../rtl/imem.vhd`
- `../rtl/main_decoder.vhd`
- `../rtl/mux2.vhd`
- `../rtl/mux3.vhd`
- `../rtl/regfile.vhd`
- `../rtl/riscv_single.vhd`
- `../rtl/seven_seg_decoder.vhd`
- `../rtl/top.vhd`

Top-level entity:
- `top`

If Quartus still fails to find the MIF, the fallback is to copy `../mem/imem.mif`
into this folder and temporarily change `rtl/imem.vhd` back to `imem.mif`.
