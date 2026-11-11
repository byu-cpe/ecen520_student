# Programming the QuadSPI Flash

When you download a bitstream over JTAG, the FPGA loses its configuration as soon as the board is powered off.
The Nexys4 DDR board has a 128 Mbit QuadSPI flash memory that the FPGA can configure itself from at power-up.
This page describes how to write your design into this flash so that your board runs your design every time it is powered on.

## Generating the Flash Image

The flash cannot be programmed with the `.bit` file you normally download over JTAG.
Instead, you need a binary flash image (`.bin`) generated from a bitstream configured for the QuadSPI flash.
Build scripts that support flash programming (such as [`metastability_build.tcl`](../mmcm/metastability_build.tcl)) add the following commands after the JTAG bitstream has been written:

```
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

write_bitstream -force metastability_top_qspi.bit
write_cfgmem -force -format bin -size 16 -interface SPIx4 \
    -loadbit "up 0x00000000 metastability_top_qspi.bit" metastability_top_qspi.bin
```

These commands configure the bitstream for Master SPI x4 mode at a 33 MHz configuration clock with compression enabled, and generate two files:
* `metastability_top_qspi.bin`: the flash image you program into the flash
* `metastability_top_qspi.prm`: a text file describing the layout of the flash image

The `metastability_top_qspi.bit` file is only used to create the `.bin` file.
Do not download it over JTAG; use the regular `.bit` file for that.

## Programming the Flash with the Vivado Hardware Manager

The flash is programmed through the JTAG cable using the Vivado hardware manager.
Vivado first downloads a small "helper" bitstream into the FPGA that gives JTAG access to the flash, then writes your `.bin` file into the flash.

The Nexys4 DDR uses a Spansion S25FL128S flash.
The Vivado name for this part is `s25fl128sxxxxxx0-spi-x1_x2_x4`.

### Command Line (TCL)

Start Vivado in TCL mode from the directory containing your `.bin` file:
```
$ vivado -mode tcl
```

Open the hardware manager and connect to your board (see [here](./vivado_command_line.md#hardware-manager) for more details):
```
Vivado% open_hw_manager
Vivado% connect_hw_server
Vivado% open_hw_target
Vivado% current_hw_device [get_hw_devices xc7a100t_0]
```

Add the flash memory device to the FPGA:
```
Vivado% create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {s25fl128sxxxxxx0-spi-x1_x2_x4}] 0]
Vivado% set cfgmem [get_property PROGRAM.HW_CFGMEM [current_hw_device]]
```

Specify the flash image and the programming options (erase, program, and verify):
```
Vivado% set_property PROGRAM.FILES [list metastability_top_qspi.bin] $cfgmem
Vivado% set_property PROGRAM.PRM_FILE {metastability_top_qspi.prm} $cfgmem
Vivado% set_property PROGRAM.ADDRESS_RANGE {use_file} $cfgmem
Vivado% set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $cfgmem
Vivado% set_property PROGRAM.BLANK_CHECK 0 $cfgmem
Vivado% set_property PROGRAM.ERASE 1 $cfgmem
Vivado% set_property PROGRAM.CFG_PROGRAM 1 $cfgmem
Vivado% set_property PROGRAM.VERIFY 1 $cfgmem
Vivado% set_property PROGRAM.CHECKSUM 0 $cfgmem
```

Download the helper bitstream into the FPGA so that it can access the flash:
```
Vivado% create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]
Vivado% program_hw_devices [current_hw_device]
Vivado% refresh_hw_device [current_hw_device]
```

Program the flash (this takes about a minute):
```
Vivado% program_hw_cfgmem -hw_cfgmem $cfgmem
```

Once programming has completed, reconfigure the FPGA from the flash and close the hardware manager:
```
Vivado% boot_hw_device [current_hw_device]
Vivado% close_hw_manager
```

The `boot_hw_device` command does the same thing as pressing the "PROG" button on the board.
If JP1 is in the "QSPI" position (see [below](#jumper-settings)), your design should now be running.

### Vivado GUI

You can also program the flash from the hardware manager in the Vivado GUI:
1. Open the hardware manager and select "Open Target" -> "Auto Connect".
2. Right-click on the `xc7a100t_0` device and select "Add Configuration Memory Device".
3. Select the `s25fl128sxxxxxx0-spi-x1_x2_x4` part (type `s25fl128s` in the search box) and click OK.
4. When asked whether to program the configuration memory device now, click OK.
5. Select your `.bin` file as the "Configuration file" and your `.prm` file as the "PRM file".
6. Leave the "Erase", "Program", and "Verify" options checked and click OK.
7. When programming completes, right-click on `xc7a100t_0` and select "Boot from Configuration Memory Device" (or press the "PROG" button on the board).

## Jumper Settings

The JP1 jumper determines where the FPGA loads its configuration from at power-up.
* To have the board load your design from the flash every time it is powered on, move JP1 to the "QSPI" position.
* JTAG downloading works with JP1 in either position, so you can leave JP1 in the "QSPI" position and still download bitstreams over JTAG as described [here](./download.md).

If JP1 is in the "JTAG" position, the FPGA will not load from the flash at power-up or when "PROG" is pressed; it waits for a JTAG download instead.
You can program the flash with JP1 in either position.

Once programmed, the flash keeps your design until it is erased or overwritten, even when the board is powered off.

## Troubleshooting

* **The flash part does not match**: Some board revisions may use a different flash part.
If `program_hw_cfgmem` reports an ID mismatch, check the part number printed on the flash chip and select the matching part from `get_cfgmem_parts`.
* **The design does not start after power-up**: Make sure JP1 is in the "QSPI" position and that the `.bin` file was generated from the `_qspi.bit` bitstream (with `CONFIG_MODE SPIx4` set), not from the JTAG `.bit` file.
* **Erasing the flash**: To return the board to its original behavior, program the flash again with a different design or set `PROGRAM.CFG_PROGRAM 0` and `PROGRAM.VERIFY 0` before running `program_hw_cfgmem` to only erase it.
