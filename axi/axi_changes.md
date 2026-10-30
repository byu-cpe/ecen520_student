# AXI Assignment: Pending Changes

Review notes for `axi.md`, `passoff.py`, `report.md`, and the provided files (`uart_axi_template.sv`, `uart_axi_tb_template.sv`, `uart_axi_wrapper.v`, `create_vip_files.tcl`).
Line numbers refer to `axi.md` at the time of review and may have shifted.
The commented student feedback at the end of `axi.md` (lines 184–189) asks for a diagram, a clearer simulation process, a more involved report, and a step-by-step description of a transaction. Several items below address that feedback.

## Glaring issues

- [ ] **The status register has no "TX FIFO empty" bit, but the testbench requires checking it.** Testbench step (line 149): "Read the status register to make sure the tx FIFO is not empty." The status register (lines 90–99) only has TX FIFO *full* and RX FIFO *empty*.
  - Add a TX FIFO empty bit (and an RX FIFO full bit for symmetry).
  - Add the new bits at bit 7 and above so the existing bits keep their positions. The MicroBlaze software (`microblaze/mb_uart.c`) uses `RX_EMPTY_MASK 0x10` (bit 4).
- [ ] **The `build_vip` log name doesn't match passoff.** The md says to run `vivado -mode batch -source create_vip_files.tcl` (line 130), which writes `vivado.log`. Passoff expects `build_ip.log` from the `build_vip` rule.
  - Tell students to add `-log build_vip.log` and change passoff to match (or tell them to use `-log build_ip.log`).
  - The simulation instructions also refer to "the `build_ip` rule" (lines 157–158); the rule is `build_vip`.
- [ ] **The testbench wiring instructions are backwards** (lines 140–141).
  - "Instance a transmitter module into your testbench and attach it to the output of your AXI UART module": the testbench transmitter drives the UART's *input* (`rx_in`).
  - "Instance a receiver module into your and attach it to the output": missing "testbench"; this one does attach to the output (`tx_out`).
- [ ] **There is no description of the AXI4-Lite handshake requirements.** This is the hardest part of the assignment, and the student feedback (line 188) says students spent a lot of time on an incorrect design. See the "AXI4-Lite interface" section below.

## FIFO

- [ ] **Give a port table**, as the other labs do. The FIFO is reused by `uart_axi` and the MicroBlaze lab, so consistent names help. For example: `clk`, `rst`, `clr`, `we`, `din`, `re`, `dout`, `full`, `empty`, `overflow`, `underflow`.
- [ ] **Explain the read behavior ("first-word fall-through").** "Reads should be asynchronous" (lines 17 and 23) is easy to misread. State that `dout` always shows the entry at the read pointer (asynchronous distributed RAM read), and that asserting `re` advances the read pointer at the next clock edge. Explain why this matters: the TX state machine and the AXI read can use `dout` in the same cycle they assert `re`.
- [ ] **Remove the duplicated bullets.** "The writes should be synchronous" / "Reads should be asynchronous" appear both under the storage bullet (lines 16–17) and under the port bullets (lines 20, 23).
- [ ] **Say whether `overflow` and `underflow` are sticky.** The testbench ("verify that the fifo error is cleared", lines 40, 42) implies they stay set until `clr` or `rst`. State it explicitly, and say that writes when full and reads when empty are ignored (the pointers don't move).
- [ ] **Specify simultaneous read and write** when full and when empty, as the bram lab does (lines 30–33 of `bram.md`).
- [ ] **Say how full and empty are detected** (an extra pointer bit or an entry count), and whether `DEPTH` must be a power of 2. With the default `DEPTH = 32`, the storage maps naturally to `RAM32M` / `RAM32X1D` primitives.
- [ ] **Specify the reset polarity.** The FIFO reset is presumably active high, while the AXI reset (`s_axi_aresetn`) is active low. Say that `uart_axi` must invert it.
- [ ] **Point to the specific UG901 section** ("Distributed RAM Examples", line 14) with a direct link, as was done for `ASYNC_REG` in the mmcm lab.

### FIFO testbench

- [ ] **Add tests:**
  - check the data values read back (not just the flags);
  - pointer wraparound (write and read more than `DEPTH` bytes in total);
  - simultaneous read and write;
  - `full` and `empty` deasserting at the right times.
- [ ] **Require self-checking.** Count errors and print a final summary, and add a passoff `file_regex_check` on `sim_fifo.log` (as in other labs).
- [ ] **Clarify the bram reference.** "Very similar to the bram fifo testbench" (line 35): say which file (the student's own testbench from the bram lab), since the bram FIFO has a different interface (synchronous BRAM read, no overflow/underflow).

## Transmitter and receiver paths

- [ ] **Warn about the TX double-send race.** After asserting `send`, the transmitter's `busy` may not rise until the next cycle. A state machine that checks "FIFO not empty and not busy" every cycle can pop and send two bytes. Suggest a small state machine (IDLE → SEND → WAIT_BUSY → IDLE) or waiting for `busy` to rise.
- [ ] **Describe the receiver handshake.** The rx module has `Receive` / `ReceiveAck`. The "logic/state machine that writes a byte to the receiver FIFO" (line 72) should say to write `Dout` into the RX FIFO when `Receive` is asserted and then assert `ReceiveAck`.
- [ ] **Specify parity error handling.** Are bytes with a parity error written to the RX FIFO or dropped? What sets and clears "RX error status" (status bit 2)? Suggest: the byte is still written, and the error bit is sticky until the RX FIFO is cleared.
- [ ] **Handle a received byte when the RX FIFO is full.** That data is lost, and nothing in the status register reports it. Add an "RX overflow" status bit. (The current bits are TX overflow from AXI writes and RX underflow from AXI reads; RX overflow from the UART side is the case software most needs to know about.)

## AXI4-Lite interface

- [ ] **Add a block diagram** of `uart_axi`: AXI write channels → TX FIFO → TX state machine → `tx`; `rx` → RX FIFO → AXI read channels; status and control registers. This was requested in the student feedback (line 185). An SVG/PNG like the mmcm metastability figure would work.
- [ ] **Add a description of the handshake rules** students must follow. At minimum:
  - A transfer happens on a channel when `VALID` and `READY` are both high on a rising clock edge.
  - The master may present `AWVALID` and `WVALID` in either order or in the same cycle. The subordinate must handle all three cases (a common simplification: wait until both are valid, then assert `AWREADY` and `WREADY` together for one cycle).
  - Once `BVALID` or `RVALID` is asserted, it must stay asserted (with stable data) until `BREADY` / `RREADY` is high.
  - `VALID` must not depend on `READY` (a subordinate may make `READY` depend on `VALID`).
  - Only one outstanding transaction per direction is needed for AXI4-Lite in this design (e.g., don't accept a new read address while `RVALID` is still waiting for `RREADY`).
- [ ] **Add a step-by-step example of one write and one read**, with a timing diagram: AW/W handshake → FIFO write → B response; AR handshake → FIFO read → R response. This was requested in the student feedback (line 188). Also say explicitly that the UART receive path (filling the RX FIFO) and the AXI read path (emptying it) operate independently; the feedback says this was the main source of confusion.
- [ ] **Define the address decode.** `C_S_AXI_ADDR_WIDTH = 4` gives four 32-bit word offsets (0x0, 0x4, 0x8, 0xC). Say which address bits to decode (e.g., `addr[3:2]`), and what offsets 0x08 and 0x0C do (read 0 with `OKAY`, or return `SLVERR`).
- [ ] **Define the data width and byte lanes.** The RX data read returns the byte in bits [7:0] with bits [31:8] = 0. Status bits [31:N] are 0. Say whether `WSTRB` is ignored (simplest) or must have bit 0 set to write.
- [ ] **Define the response codes.** Say whether everything returns `OKAY` (`2'b00`), or whether errors (writing a full TX FIFO, reading an empty RX FIFO, an unused address) return `SLVERR` (`2'b10`).
- [ ] **Define read side effects.**
  - A read of offset 0x00 pops one byte from the RX FIFO; say on which handshake (AR or R) it happens, and that it must happen exactly once per read.
  - Say what a read returns when the RX FIFO is empty (e.g., 0, with the underflow bit set).
  - A write to 0x00 when the TX FIFO is full drops the byte and sets the overflow bit.
- [ ] **Define the control register semantics.**
  - Are the clear bits one-cycle pulses (self-clearing), or levels that hold the FIFOs clear while set? Recommend pulses.
  - The MicroBlaze software writes `switches & 0x3` to this register at startup (`mb_uart.c` line 86). With level semantics, the FIFOs would stay cleared as long as a switch is on.
  - Say whether clearing a FIFO also clears its sticky error bits (overflow, underflow, RX error).
- [ ] **Define the "TX Busy" status bit.** Is it the transmitter's `busy`, or "busy or TX FIFO not empty" (i.e., still has data to send)? Software usually wants the second.
- [ ] **Describe the reset.** `s_axi_aresetn` is active low and synchronous. Say that it resets the FIFOs, the UART modules, and the AXI state, and that `BVALID` / `RVALID` must be low during reset.
- [ ] **Add references:**
  - the course AXI lectures (`../lectures/axi.md`);
  - the AMBA AXI protocol specification (ARM IHI 0022), AXI4-Lite section;
  - the AMD AXI Reference Guide (UG1037).

## Provided files

- [ ] **Parameter defaults and types are inconsistent:**
  - `BAUD_RATE`: 115,200 in `uart_axi_template.sv` and `uart_axi_tb_template.sv`, 19,200 in `uart_axi_wrapper.v`, and the MicroBlaze notes mention 9600. Pick one default and say which baud rate the MicroBlaze lab uses.
  - `PARITY`: `logic` in the templates, `integer` in the wrapper and the tx lab spec. Use `integer` everywhere.
- [ ] **`uart_axi_wrapper.v` isn't mentioned in `axi.md`**, but the MicroBlaze lab requires it ("Your fifo, uart_axi, and uart_axi_wrapper from the axi assignment"). Explain that it is a Verilog wrapper for the block diagram (which doesn't accept SystemVerilog). Consider synthesizing through the wrapper in `synth_uart_axi` so problems show up in this lab. Fix its header comment (`// uart_axi.v`).
- [ ] **Consider exposing a `FIFO_DEPTH` parameter** on `uart_axi` (passed to both FIFOs).
- [ ] **`uart_axi_tb_template.sv`:**
  - Signal names copied from a block design (`clk_wiz_clk_out1`, `rst_clk_wiz_100M_peripheral_aresetn`, `design_1_uart_axi_0_0`) are confusing in a testbench. Rename them to `clk`, `aresetn`, `uut`.
  - The template has no clock generator, and the md says to create the clock "in your initial block" (line 145). A clock needs its own `always`/`initial` block; provide it in the template.
  - `timescale 1ps/1ps` differs from the other labs (`1ns/1ps`).
  - Explain the example calls (`AXI4LITE_READ_BURST` / `AXI4LITE_WRITE_BURST`): the arguments, that they block until the transaction completes, and how to check `resp`. Explain that the address `0x44A0_0000` in the examples is arbitrary, because only bits [3:0] are connected.
  - Say how long to hold `aresetn` low (Xilinx IP typically requires at least 16 clock cycles; confirm what the VIP requires) and that `start_master()` must be called before any transaction (it already is in the template).
- [ ] **`create_vip_files.tcl`:** the md says "This script when run within the Vivado Tcl console" (line 129) but then runs it in batch mode. Remove the Tcl console wording. Typo: "A scripted named" → "A script named" (line 128).

## Simulation setup

- [ ] **Give a complete makefile example** for `sim_uart_axi`, so students don't have to piece it together from the bullets (lines 156–166). The student feedback asks to "clarify the process for simulating".
- [ ] **Avoid editing `modelsim.ini` by hand.** Use `vmap` commands in the makefile (as `resources/questa_tutorial.md` does for `unisims_ver`). The library paths are hard-coded to `/tools/Xilinx/Vivado/2024.1`, and the library name `axi_vip_v1_1_17` changes with the Vivado version. Put the version in one makefile variable.
- [ ] **Explain why each library is needed:** `xilinx_vip` contains `axi_vip_pkg` (imported by the testbench), and `axi_vip_v1_1_17` contains the VIP top module that `axi_vip_0.sv` instantiates.
- [ ] **Mention the VIP protocol checker.** The AXI VIP checks the protocol and reports violations in the simulation log. Tell students to look for VIP errors and warnings in `sim_uart_axi.log`; this is the fastest way to find handshake bugs.
- [ ] **Clean rule:** say what to remove (`ip/`, Questa `work/`, `.Xil/`, logs) in addition to adding `ip/` to `.gitignore`.

## AXI UART testbench

- [ ] **Require self-checking.** Compare the bytes received by the testbench receiver with the bytes written over AXI, and the bytes read over AXI with the bytes sent by the testbench transmitter. Check the status register values against expected values (after reset, after writes, after clear). Print an error count, and add a passoff regex check on `sim_uart_axi.log`.
- [ ] **Add tests:**
  - TX FIFO overflow (write more than `DEPTH` bytes, check the overflow bit);
  - RX underflow (read an empty RX FIFO);
  - the control register clears (check the status afterwards, which the current step list doesn't do, line 154);
  - back-to-back AXI transactions;
  - a parity error (the testbench transmitter can be instanced with the opposite parity).
- [ ] **Give the expected status register value after reset** (e.g., RX FIFO empty = 1, TX FIFO empty = 1, all others 0) so students know what "verify that the value is correct" (line 147) means.
- [ ] **Explain "Wait for these bytes to be transferred"** (line 151): at 115,200 baud a byte takes about 95 µs, so suggest polling the status register or waiting on a testbench event rather than a fixed delay.
- [ ] Typos: "This receiver is use in the testbench" → "used"; "transmitted from your testbench tx module and to the receiver" → "transmitted by your testbench tx module to the receiver" (line 142).

## Synthesis

- [ ] **Give the synthesis commands**, as the other labs do:
  - the file list (`uart_axi.sv`, `fifo.sv`, and the tx and rx files from earlier labs, e.g. `../tx_sim/tx.sv` and `../rx_sim/rx.sv`);
  - `-top`;
  - the part.
- [ ] **Use out-of-context synthesis** (`synth_design -mode out_of_context`) for `synth_fifo` and `synth_uart_axi`. These modules aren't top-level designs with pin constraints, so normal synthesis inserts I/O buffers for every port and may report errors or warnings that don't matter.
- [ ] **Add a clock constraint** (e.g., `create_clock -period 10 [get_ports s_axi_aclk]`) so the synthesis timing estimate is meaningful.
- [ ] **Remove the commented-out `synth_axi` section** (lines 107–112). It duplicates `synth_uart_axi`.
- [ ] **Make "Review the synthesis report to identify any potential problems" (line 177) specific:**
  - no latches;
  - two FIFOs implemented in distributed RAM (`RAM32M` or similar);
  - no multi-driven nets;
  - no unexpected removed logic (e.g., an unconnected status bit).

## passoff.py

- [ ] Fix the `build_vip` log name (see Glaring issues).
- [ ] Add regex checks on `sim_fifo.log` and `sim_uart_axi.log` for the self-checking error summaries.
- [ ] If `synth_uart_axi` synthesizes through the wrapper, add `uart_axi_wrapper.v` to its input files (currently `["uart_axi.sv", "fifo.sv"]`).
- [ ] Consider checking that `ip/` is not committed (it's in `.gitignore`).

## report.md

The report has one question ("Discuss any unique warning messages…"). The student feedback asks for a more involved report. Suggested questions:

- [ ] Describe how your design handles the AW and W channels (wait for both, or accept them independently), and why.
- [ ] Include a waveform screenshot of one AXI write and one AXI read, with the handshakes marked.
- [ ] On which handshake does a read of the RX data register pop the RX FIFO? What does your design return when the RX FIFO is empty?
- [ ] What is the status register value immediately after reset? Explain each bit.
- [ ] How many distributed RAM primitives (and LUTs and flip-flops) does `uart_axi` use? Does this match two FIFOs of `DEPTH` × 8?
- [ ] How long (in µs) does it take to transmit the bytes in your testbench at the chosen baud rate, compared with the time for the AXI writes that put them in the FIFO? Why is a FIFO needed?

## Coding standard and general

- [ ] State which coding standard level applies (Level 2 or 3), as the other labs do.
- [ ] Say where the tx and rx modules come from, and that students should reference them with relative paths rather than copying them (as in tx_download).
- [ ] The "subordinate/slave" wording is used consistently; consider defining both terms once (AXI4 now uses manager/subordinate).
