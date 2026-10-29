# SPI Download Assignment: Pending Changes

Review notes for `spi_download.md`, `passoff.py`, and `report.md`, checked against the revised `spi_cntrl` lab (single `adxl362_cntrl` module) and `../spi_cntrl/adxl362_model.sv`.
Line numbers refer to `spi_download.md` at the time of review and may have shifted.

The dependency on `adxl362_cntrl` holds up: `spi_download.md` never names its ports, so the rename to `read` / `write_data` / `read_data` breaks nothing.

## passoff.py vs spi_download.md

- [ ] **The top-level simulation log is never checked for errors.**
  - spi_cntrl now requires an `Error:<adxl362_cntrl_tb>` string and checks for it. This lab requires no self-checking at all.
  - In the testbench section, require `Error:<adxl362_top_tb>` on a wrong read value.
  - Add the matching check to passoff:
    ```python
    tester.add_build_test(repo_test.file_regex_check("sim_adxl362_top.log", "Error:<adxl362_top_tb>",
                                                     "ADXL362 Top Testbench", error_on_match = True,
                                                     error_msg = "adxl362_top testbench failed"))
    ```
  - The testbench needs something to check against. The read value only reaches the seven-segment outputs, so either name an internal register it may reference hierarchically (e.g. `dut.read_value`), or explain how to decode the displayed digits.
- [ ] **The .xdc file has no name** (Synthesis section: "Create a .xdc constraints file").
  - Name it (e.g. `adxl362_top.xdc`).
  - Add `["adxl362_top.sv", "adxl362_top.xdc"]` as the required inputs of `synth_adxl362_top`, which currently lists `[]`.
- [ ] **`adxl362_top.dcp` is listed twice** in the `implement_adxl362_top` outputs. It's harmless; remove the duplicate.
- [ ] **The Submission section lists no deliverables.** It only says "make sure your `passoff.py` script runs". spi_cntrl now lists its rules and files explicitly. List:
  - Rules: `sim_adxl362_top`, `synth_adxl362_top`, `implement_adxl362_top`.
  - Screenshots: `clock_pin.png`, `bufg.png`, `btnr_sync.png`, all committed (passoff checks they are tracked; the md doesn't say to commit them).
- [ ] Rule names, log/dcp/bit/rpt file names, and screenshot names otherwise match passoff.

## Consistency with spi_cntrl and the ADXL362 model

- [ ] **The STATUS value doesn't match.** The testbench section says "should get 0x40 on power up (0xC0?)". `adxl362_model.sv` returns 0x41, spi_cntrl says 0x41, and the Download section of this md says 0x41. Change it to 0x41 and drop "(0xC0?)".
- [ ] **Say where the reused modules come from.**
  - `adxl362_cntrl.sv` comes from `../spi_cntrl`, and the sim and synth rules must compile it (along with `../spi_cntrl/adxl362_model.sv` for simulation).
  - "Instance your seven segment display controller" doesn't say which lab it comes from (rx_download). The debouncer comes from an earlier lab too.
- [ ] **`done` pulses for writes too.** In spi_cntrl, `done` is asserted at the end of every transaction. The top level should latch `read_data` into the digits-0/1 display register only when the finished operation was a button-initiated *read*.
- [ ] **Parameters to pass through:** `adxl362_cntrl` takes `CLK_FREQUENCY` and `SCLK_FREQUENCY`. Say the top level passes both. The default here (1 MHz) differs from spi_cntrl's (500 kHz), which is fine but worth a sentence.

## Top-level design: missing specification

- [ ] **Un-comment and expand the note on how the top level shares the controller** (the HTML comment after the Seven Segment Display bullets). The active text never says:
  - that one `adxl362_cntrl` is shared by two users: the button/switch reads and writes, and the periodic X/Y/Z reader;
  - which user has priority when both need the controller;
  - that a pending button request must be latched. `adxl362_cntrl` only samples `start` in IDLE, so "the operation should proceed when the interface is no longer busy" needs a pending-request flag in the top level;
  - that the periodic reads must not overwrite the button-read byte shown on digits 1–0. Keep separate registers for that byte and for X, Y and Z.
- [ ] **Buttons need one-shot / edge detection** after the debouncer (rx_download says this). Otherwise holding a button fires repeated operations.
- [ ] **X/Y/Z will read 0 on a freshly powered board.**
  - The ADXL362 powers up in standby. Nothing in the lab writes 0x02 to POWER_CTL (0x2D) before the continuous display is expected to work. That step appears only in the soft-reset note at the end.
  - Option A: have the top level write POWER_CTL once after reset (a small init state in the FSM).
  - Option B: make "enable measurement" the first step of the Download section.
- [ ] The `BTNL`, `BTNR`, and `LED16_B` rows in the port table have empty Function columns.

## Testbench

- [ ] **The default parameters are too slow to simulate.**
  - `DEBOUNCE_TIME_US = 10_000` is 1M cycles per button press.
  - `DISPLAY_RATE = 2` is 50M cycles between X/Y/Z updates.
  - Tell students to override these in the testbench (e.g. a ~10 µs debounce and a high `DISPLAY_RATE`) so the simulation finishes and shows at least one periodic X/Y/Z read.
- [ ] **Writes can't be read back in simulation.** The model doesn't store writes, so the 0x52 → 0x1F write can't be verified by reading it back. Say so, and point students to the model's `ADXL362: Received Value 0x52` message.
- [ ] Optionally require at least one periodic X/Y/Z read cycle in the log. The model returns random values for 0x08–0x0A, so print them rather than check them.

## Constraints text

- [ ] **"None of the inputs are registered" / "The outputs are also not registered" is wrong.**
  - The inputs go through synchronizers, and `spi_cs` / `spi_sclk` / `spi_mosi` come from registers in `adxl362_cntrl`.
  - The real reason for the false paths is that there's no board-level I/O timing to constrain (no external input/output delays are known).
  - `ACL_MISO` goes straight into the receive shift register without a synchronizer. That's fine at a 1 MHz SCLK, but it's the path the commented-out `set_property IOB TRUE` idea would improve. It's a candidate for the "exercise" suggested in the feedback notes.

## Download section

- [ ] **Merge the reset instructions into one "Put the board in a known state" section, placed before the test steps.**
  - The 3-step reset sequence (0x52 → 0x1F, 0x00 → 0x1F, 0x02 → 0x2D) appears twice ("heads up" paragraph and "Other operations").
  - The heads-up paragraph is in a student's voice ("like I did").
  - This also covers the feedback note about boards left "locked" by previous students, and the POWER_CTL item above.
- [ ] **Check the FILTER_CTL rate.** "Write the value 0x14 to register 0x2C … (50Hz)": if I recall the data sheet correctly, ODR = bits [2:0], so 0x13 (reset) = 100 Hz, 0x14 = 200 Hz, and 0x12 = 50 Hz. Check against the FILTER_CTL table before changing it.
- [ ] **The axis descriptions contradict each other.**
  - If X runs left to right, tilting left/right changes X, and tilting toward/away changes Y. The text says the opposite for both.
  - Z also changes when the board is tilted or flipped, not only when it's lifted or dropped.
- [ ] "Note that I once received a 0xC0 after power up…" could become part of the known-state section ("if STATUS reads 0xC0, perform the reset sequence").

## Typos and wording

- [ ] Intro: "a top-level design that communicate" → "communicates".
- [ ] `DEBOUNCE_TIME_US` row: "(1 us)" → "(10 ms)" (matches rx_download).
- [ ] "accelerator values" → "accelerometer values".
- [ ] "see below for details on now to display" → "how".
- [ ] "to allow the user can easily verify" → "so the user can easily verify".
- [ ] "This insures" → "ensures".
- [ ] "top-level AXDL362L controller" → "ADXL362".
- [ ] "Add makefile rules named `sim_adxl362_top`" → "a makefile rule".
- [ ] "Create makefile rule named `implement_adxl362_top`" → "Create a makefile rule".
- [ ] "Filter Control Register control register" → "Filter Control register".
- [ ] "Tilting the board righ and to the left" → "right".
- [ ] "around different axis" → "axes".

## report.md

- [ ] No changes required for consistency. Optionally:
  - Add a question on how the shared-controller arbitration was handled (priority, pending request).
  - Ask for the measured X/Y/Z values in a flat orientation (e.g. Z ≈ 1 g).
