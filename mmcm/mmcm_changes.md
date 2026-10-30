# MMCM Assignment: Pending Changes

Review notes for `mmcm.md`, `passoff.py`, and `report.md`.
Line numbers refer to `mmcm.md` at the time of review and may have shifted.
The board part is `xc7a100tcsg324-1` (-1 speed grade), which matters for several of the clocking items below.

All rule names and output file names in the md match passoff.py (`sim_mmcm_top`, `synth_mmcm_top`, `implement_mmcm_top`, and their .log, .dcp, .bit and .rpt files).

## Glaring issues

- [ ] **A TODO note is visible to students** (Synthesis section, ~line 179): "TODO: Hve the students run the `report_cdc` command…".
  - Either comment it out, or make it a real requirement.
  - If it becomes a requirement: say which rule runs `report_cdc -details -file cdc_report.rpt` (after `check_timing`), name the file (e.g. `cdc_mmcm_top.rpt` to match the other reports), add it to passoff's build files, and add a report.md question about what it found.
  - See **Proposal 1** at the end of this file.
  - The inline code also has a stray backtick on its own line.
- [x] **Waveform screenshots are not checked by passoff.** The md requires `mmcm_clk0.png` … `mmcm_clk6.png`, and report.md links them, but passoff doesn't check them. Add:
  ```python
  tester.add_required_tracked_files([f"mmcm_clk{i}.png" for i in range(7)])
  ```
  - *Resolved:* added to `passoff.py`.
- [x] **The seven-segment parameter doesn't match the student's existing module.**
  - The parameter table has `SEGMENT_DISPLAY_US = 1_000`.
  - Every other lab, and the `seven_segment8` module from rx_sim, uses `REFRESH_RATE` (Hz, default 200).
  - Use `REFRESH_RATE` here, or explain how to convert.
  - *Resolved:* replaced `SEGMENT_DISPLAY_US` with `REFRESH_RATE` (default 200 Hz) in the parameter table, noting it is passed to `seven_segment8`.
- [ ] **The simulation library setup is only in an HTML comment** (the "Tips" block at the end).
  - Without it, `MMCME2_BASE` won't simulate: students need the unisim Verilog library and `glbl`.
  - The commented tips use `xvlog` (Vivado xsim), but the course uses Questa elsewhere (the bram lab uses `modelsim.ini` and `vsim -L unisim`).
  - Write one consistent, un-commented set of instructions: `-L unisims_ver` (check whether `unisim` is right for Verilog models; see `../bram/bram_changes.md`), plus `glbl` on the `vsim` command.
  - The same hard-coded `/tools/Xilinx/...` path concern as the bram lab applies.
- [x] **The MMCM site name format is garbled** (Implementation section): "MMCME2_ADV_XxYx where 'a' is a letter and 'x' is a number". Same fix as bram_download: "something like `MMCME2_ADV_X#Y#`, where each `#` is a number (e.g. `MMCME2_ADV_X1Y2`)". *Resolved.*
- [x] **"two MCM primitives" / "2 MCMs"** (Synthesis section) → "MMCM". Also mention that each `MMCME2_BASE` appears as `MMCME2_ADV` in the synthesis log and utilization report, so students know what to look for. *Resolved:* "MCM" → "MMCM", and added a sentence saying to look for two `MMCME2_ADV` cells.
- [x] **The port table has two columns swapped:** the `CA, CB, …` row reads "| 1 each | Output |" (Width and Direction swapped). *Resolved.*

## Main MMCM: clocking specification

- [x] **The figure references don't say which document they're from.** "Figure 3-11" (deskew) and "Figure 3-13" (no deskew) are in the *7 Series Clocking Resources User Guide (UG472)*, which is never named or linked. Add the link, and cite figure titles rather than numbers (numbers change between revisions).
  - *Resolved:* added a UG472 link (docs.amd.com, verified) at the start of the Main MMCM section, noting the figure numbers are from v1.14 (the page didn't expose figure titles, so the numbers are pinned to a version instead). Both references now read "UG472, Figure 3-11/3-13".
- [x] **The library guide link is out of date:** UG953 for **2012.2**. Point to the current UG953 on docs.amd.com.
  - *Resolved:* now links to https://docs.amd.com/r/en-US/ug953-vivado-7series-libraries (verified, 2026.1).
- [ ] **"Use the board RST to reset this MMCM"** → name the port (`CPU_RESETN`). Note that it is active low while the MMCM `RST` input is active high, so it must be inverted (after the synchronizer).
- [x] **Give the VCO constraints.** Students must choose M (`CLKFBOUT_MULT_F`), D (`DIVCLK_DIVIDE`), and each `CLKOUTn_DIVIDE` so that every requirement is met by one shared VCO. The guidance is only in an HTML comment, and it may be wrong for this board:
  - The comment says Fvco = 600–1600 MHz, so M/D = 6–16. I believe 1600 MHz is the -3 limit, and the **-1 speed grade limit is 1200 MHz** (M/D = 6–12 with a 100 MHz input). Check against the Artix-7 data sheet (DS181, MMCM switching characteristics) before publishing.
  - The PFD input (Fin/D) also has a minimum (10 MHz), which limits D. That matters for the secondary MMCM's prime M and D.
  - Since CLKOUT0 must be 100 MHz and in phase (deskew), Fvco must be an integer multiple of 100 MHz. Saying so saves students a lot of trial and error.
  - *Resolved:* added a VCO paragraph after the clock output list: the Fvco and Fout formulas, the 600–1200 MHz -1 limit (M/D = 6–12, DS181 linked), Fin/D ≥ 10 MHz (D ≤ 10), and the integer multiple of 100 MHz rule (CLKOUT1/2 can't use a fractional divide). The Secondary MMCM section now repeats the limits, so D must be 2, 3, 5 or 7. The HTML comment was updated from 1600 to 1200.
- [x] **"Out of phase with input" (CLKOUT3, CLKOUT4) is vague.** Give a specific phase (e.g. 45° or 90°), or say "any non-zero phase shift, stated in your report".
  - *Resolved:* both now say "any non-zero phase shift is acceptable".
- [x] **The CLKOUT4 requirements are inconsistent:** "at least 2.5x greater than input clock" (Main MMCM section) vs "CLKOUT4 domain (>250 MHz)" (CDC section). Use one: "≥ 250 MHz".
  - *Resolved:* both now say at least 2.1x the input (≥ 210 MHz).
- [x] **A 48-bit counter at ≥ 250 MHz probably won't meet timing on a -1 part.** A 48-bit ripple-carry adder is 12 CARRY4s plus routing. Line 206 says "Make sure your design meets the timing constraint", so students may be stuck. Options:
  - cap CLKOUT4/CLKOUT6 at a lower frequency;
  - allow a pipelined or split counter in fast domains;
  - say timing failures in the fast counters are expected, and ask about them in the report.
  - Worth a quick trial implementation before the semester.
  - *Resolved:* the minimum is lowered to 210 MHz, and a note says timing at ≥ 250 MHz may be difficult on this part (although it has been done), so a frequency closer to 210 MHz is easier.
- [x] **Clock naming is inconsistent:** "CLK0", "CLKOUT0", and "the top-level clock" are used interchangeably (e.g. "uses CLK0 as the input clock" in the Secondary MMCM section). Pick one name per clock.
  - *Resolved:* added a clock-names list to the Main MMCM section (input clock = `CLK100MHZ`, CLKOUT0–CLKOUT6, and CLKB for the secondary MMCM output). Replaced all uses of "CLK0", "top-level clock", "100 MHz board clock", "this new clock domain", and "CNTB_0 clock domain".
- [ ] **Using CLK100MHZ in the fabric:** the seven-segment display must run on the free-running input clock, which goes to both the MMCM and a BUFG. One of the commented notes asks, "Why can't you have a bufg on the input clock?" Add a sentence on how to do this (IBUF → BUFG for the fabric, IBUF → MMCM `CLKIN1`). Check whether Vivado raises a `CLOCK_DEDICATED_ROUTE` issue with this topology; if it does, give the fix.

## Clock domain resets

- [x] **Say which `LOCKED` drives each reset chain.** The CNTB_0 domain comes from the secondary MMCM, so its reset chain should be preset by the *secondary* MMCM's `LOCKED`, not the main one.
  - *Resolved:* the reset-chain bullets now say to preset with the `LOCKED` of the MMCM that generates the domain: the main MMCM's for CLKOUT0–6, the secondary MMCM's for CLKB.
- [X] **The Mark Harvey link may be dead** (markharvey.info). Check it, and consider copying the figure or describing the circuit in the md so it doesn't depend on a third-party site. *Resolved*. A copy of the image is included in the repo and a link to the reference on where the image is found.
- [x] Typo: "asserted immediacy" → "immediately". *Resolved.*

## Clock domain crossing

- [x] **Give a hint for PULSE4 (fast → slow).** The md says "make sure you do not miss any PULSE4 signals" but gives no hint, and the comment block says "Give the students help on the 'stretcher' circuit". Recommend a toggle synchronizer:
  - the PULSE4 domain flips a toggle flop on each pulse;
  - the CLKOUT0 domain synchronizes it with two `ASYNC_REG` flops;
  - an XOR of the last two flops gives one CLKOUT0-cycle pulse per PULSE4.
  - This avoids latches entirely (the comment wonders about `always_latch`; the toggle synchronizer avoids latches completely).
  - *Resolved:* added a brief hint without implementation detail to the PULSE4CNT bullet: "Consider using a pulse stretcher circuit or a toggle (non-return-to-zero) synchronizer."
- [x] **PULSE3 (slow → fast):** say it needs a synchronizer plus rising-edge detection, which is what "count once for each unique PULSE3" means.
  - *Resolved:* the PULSE3CNT bullet now explains that PULSE3 is high for several CLKOUT0 cycles, and says to synchronize it into the CLKOUT0 domain and use a rising edge detector so each pulse is counted once.
- [x] **"(<100 MHZ)" for CLKOUT3 is understated.** The requirement is "at least 6x lower", so ≤ 16.7 MHz. Also "MHZ" → "MHz".
  - *Resolved:* now reads "(≤ 16.7 MHz, since CLKOUT3 is at least 6x slower than the input clock)".
- [x] **The UG901 link is out of date** (xilinx.com 2017.4, "page 40"). Point to the current Vivado Synthesis Guide on docs.amd.com and cite the `ASYNC_REG` section rather than a page number.
  - *Resolved:* now links to the `ASYNC_REG` section at https://docs.amd.com/r/en-US/ug901-vivado-synthesis/ASYNC_REG (verified), with no page number.

## Secondary MMCM and metastability circuit

- [x] **The CNTB_0 width isn't stated.** The display table shows `CNTB_0[47:16]`, so say 48 bits. *Resolved.*
- [x] **The CNT_META width isn't stated** (displayed in full, so presumably 32 bits). *Resolved:* 32 bits.
- [x] **No-deskew configuration:** say that `CLKFBOUT` connects directly to `CLKFBIN` (no BUFG) for the internal feedback configuration. *Resolved:* added a sentence after the "Do NOT use deskewing" line.
- [ ] **Check that a prime M and D are possible** within the VCO and PFD limits (e.g. M = 31, D = 3 gives Fvco ≈ 1033 MHz; then O = 11 gives ≈ 93.9 MHz). Giving one worked example would help.
- [x] **The metastability circuit depends entirely on XAPP094 Figure 1,** an old app note (XC4000-era). Its FF labels (A, B, C, D) are used in the md ("Every time FF 'D' goes high"; "the input to the 'metastability A' FF") without being defined.
  - See **Proposal 2** at the end of this file for a replacement circuit.
  - Describe the circuit in the md (or include a small diagram) so the labels are defined.
  - The feedback notes ask, "Force them to get metastability? … See Baker's". Decide whether students are expected to observe non-zero CNT_META on the board, and say what result is expected.
  - *Resolved:* the student-built circuit was removed (commented out) and replaced by the provided stand-alone design from Proposal 2 (`metastability_top.sv`, `metastability_top.xdc`, `metastability_build.tcl`), with a circuit figure (`metastability_circuit.png`) and a new "Metastability Circuit" section.
- [ ] "(Let me know if you find some other good ones!)" is fine but informal. Consider moving it to the report suggestions section.

## Seven-segment display and mux

- [x] **Reset of the display is unclear.** "Make sure the seven segment display still displays when the reset button is pressed" means the display controller must *not* be reset by `CPU_RESETN`. Say explicitly what reset it uses (tie it inactive, or use a separate power-on reset in the 100 MHz domain). Typo: "rest process" → "reset process". *Resolved:* the display and mux register must not use `CPU_RESETN`. They use a startup reset in the 100 MHz domain: a flip-flop chain with initial values of 1 (e.g. `logic [3:0] startup_rst_sr = 4'b1111;`) that shifts in 0s, so it resets once after configuration and never again. Typo fixed.
- [x] **Switch values 0xB–0xF aren't specified.** Say to display 0, or to repeat a counter. *Resolved:* added a `0xB - 0xF | 0` row to the display table.
- [x] **Switches:** say they are synchronized into the 100 MHz domain before driving the mux select (consistent with earlier labs). *Resolved:* added a sentence requiring a two flip-flop synchronizer (100 MHz clock) on the switches before the mux select and LEDs.

## Timing constraints

- [x] **Broken formatting** at the start of the section: a `set_false_path` line in inline code with a stray backtick on the next line, duplicating the example below it. Delete it. *Resolved:* section rewritten.
- [x] **The bullet list of false-path situations renders as a code block** because it's indented 4 spaces. Remove the indentation. *Resolved:* section rewritten.
- [x] **Consider teaching clock-level constraints.** The commented notes show clock-based constraints (`set_false_path -from [get_clocks …] -to [get_clocks …]`). Two options:
  - `set_clock_groups -asynchronous` for the unrelated domains;
  - `set_max_delay -datapath_only` for CDC paths. This is better practice for multi-bit buses than a blanket `set_false_path`, and ties in with the CDC lectures and `report_cdc`.
  - See **Proposal 1** at the end of this file.
  - *Resolved:* the Timing Constraints section now uses `set_max_delay -datapath_only` instead of `set_false_path`. It explains why related clocks fail timing, what `-datapath_only` does and how it differs from a false path, lists the four crossings, gives a table for choosing X, and shows an example for all four crossings. It also lists `report_exceptions -ignored`, `report_clock_interaction`, and `report_timing_summary` as checks. Not adopted yet from Proposal 1: generated clock names and report.md questions. (`report_cdc` and `create_waiver` were later added in a new "Clock Domain Crossing Report and Waivers" subsection.)
- [x] "Make sure you add the timing false path timing constraints like you did for the last assignment": fix the repeated "timing", and name the assignment (the false-path I/O constraints were introduced in spi_download).
  - *Resolved:* now points to the Timing Constraints section and to the spi_download I/O false paths.

## Testbench

- [ ] **The testbench is hard to judge, and passoff checks nothing in the log.** Add self-checks with `Error:<mmcm_top_tb>` and a passoff `file_regex_check`, as in the other labs. Candidates:
  - each clock's period matches its expected value (measure with `$realtime` between edges);
  - the MMCMs lock;
  - PULSE3CNT and PULSE4CNT increase.
- [ ] **Simulation length.**
  - The display shows `[47:16]`, so the upper bits barely change in a short simulation.
  - `SEGMENT_DISPLAY_US = 1_000` (or `REFRESH_RATE = 200`) makes a full display cycle take ms of simulated time at ps resolution.
  - Tell students to check counters through hierarchical references (low bits) and to override the display parameter in the testbench.
- [ ] **Waveforms:** the feedback suggests one waveform with all clocks rather than seven separate screenshots. If kept as seven, say what each must show (markers for period, phase offset vs CLKOUT0/input, and duty cycle).
- [ ] The comment block asks for "the TCL commands for printing the simulation files to an image". If that's wanted, give the Questa command so screenshots are reproducible.

## Implementation

- [ ] **No report commands are given.** spi_download gives the exact `report_timing_summary` and `report_utilization` commands; repeat them here with the `_mmcm_top` names.
- [ ] **The constraints file has no name.** Name it (e.g. `mmcm_top.xdc`) and list `["mmcm_top.sv", "mmcm_top.xdc"]` as required inputs of `synth_mmcm_top` in passoff (currently `[]`).
- [ ] "Create makefile rule named" → "Create a makefile rule named".

## report.md

- [x] **The numbering has two "3."** (screenshots and Timing Report Review). Renumber. *Resolved:* the questions are now 1–6.
- [x] **The "Clock Domain Timing Table" isn't referenced by any question,** so students may skip it. Add a question that points to it. *Resolved:* added as a bullet under Timing Report Review (question 4), linking to the table.
- [x] **The timing table has no row for the secondary MMCM clock** (CNTB_0 domain); add one. Consider a "Phase" column, and the MMCM settings used (M, D, O) for each clock. *Resolved:* added the secondary MMCM row, plus "M / D / O" and "Phase" columns, and a short explanation above the table of what goes in each column.
- [x] **Utilization table typo:** "MMCME2_EDV" → "MMCME2_ADV". *Resolved.*
- [x] **Add a question on the metastability experiment:** the CNT_META value observed on the board after N seconds, and an interpretation. *Resolved:* report.md has a "Metastability Experiment" section matching the six exercises.
- [ ] If `report_cdc` is required, add a question summarizing its findings.

## Typos and wording

- [x] "with following ports and parameters" → "with the following ports and parameters".
- [x] "Old FPGA ap note" → "app note".
- [x] "Hve" → "Have" (in the TODO; moot if it's removed).
- [x] The empty first line of the file (before `# MMCM Assignment`) can be removed. *All four typos resolved.*

---

# Proposals for review

The two proposals below are larger changes that need review (and a reference implementation) before they go into `mmcm.md`.
They replace the "Timing Constraints" section and the "Metastability Circuit" section, respectively.

## Proposal 1: Clock domain crossing constraints and `report_cdc`

Related items above: the `report_cdc` TODO (Glaring issues), "Consider teaching clock-level constraints" (Timing constraints), and the `report_cdc` question (report.md).

### The problem with the current approach

- Every clock in the design is derived from `CLK100MHZ` (all MMCM outputs share one VCO, and the secondary MMCM's input is CLKOUT0). Vivado therefore treats every clock pair as **related** and times each crossing as an ordinary synchronous path.
- For a related crossing, Vivado expands both clocks over their common period and uses the closest launch/capture edge pair as the requirement. This is meaningless for a synchronizer and leads to very small requirements:

  | Crossing (example clocks) | Closest edge spacing | Result without constraints |
  | --- | --- | --- |
  | clkb → clk0 (M = 31, D = 3, O = 11; ratio 33:31) | 10/31 ≈ 0.32 ns | Fails badly |
  | clkb → clk4 (metastability circuit) | A fraction of a ns | Fails |
  | clk4 (220 MHz, 45°) → display register | ≈ 0.34 ns (3/8 of a VCO period) | Fails |
  | clk3 (phase shifted) → clk0 or display | Set by the phase shift | Probably fails |
  | clk1 (180°) / clk2 (90°) → display | 5 ns / 7.5 ns | Passes |
  | clk0, clk5, clk6 (in phase) → display | ≥ one VCO period | Probably passes |

- The `ASYNC_REG` attribute does **not** change timing analysis. It only affects placement, optimization, and `report_cdc`.
- The per-cell `set_false_path` constraints make the timing failures go away, but:
  - they are fragile (a missed crossing shows up as an unexplained failure; an over-broad wildcard hides real problems);
  - they give the tool no bound on the crossing route;
  - `report_cdc` only analyzes crossings between clocks Vivado considers asynchronous, so with cell-level false paths on related clocks it probably reports little or nothing.
- `create_waiver` does **not** affect timing. It only marks `report_cdc`, DRC, and methodology messages as reviewed.

### Proposed constraint approach

Replace the `set_false_path` section with `set_max_delay -datapath_only` on each crossing.

**What `set_max_delay -datapath_only X` does:**
- Replaces the clock-edge-derived requirement with a fixed limit X (in ns) on the data path only (clk-to-Q + logic + route + destination setup).
- Ignores the clock latency (skew) on both sides, which is meaningless between asynchronous clocks.
- Removes the hold check on the path, so the router doesn't add delay to fix a meaningless hold violation.
- The path is still timed: if placement makes the route longer than X, timing fails and the tool works to fix it. A false path is not checked at all.
- Requires a `-from` startpoint (cell or clock).
- Note: it does *not* protect the synchronizer's settling time (that is the path between the first and second synchronizer flops, which is in a single clock domain and is timed normally; `ASYNC_REG` keeps them together). It bounds the crossing latency.

**Choosing X:**

| Crossing type | Typical X | Why |
| --- | --- | --- |
| Single-bit synchronizer (PULSE3, PULSE4 toggle) | One destination clock period (or the smaller of source/destination) | Predictable crossing latency |
| Multi-bit gray-code bus (later FIFO lab) | One source clock period, plus `set_bus_skew` | Each value arrives before the next one launches |
| Counters → display register | 10 ns | Mostly to keep the path constrained |
| Metastability circuit | Small (≤ one CLKOUT4 period) | Short and repeatable data path |

Example (placeholder cell names; example clock periods):
```tcl
set_max_delay -datapath_only -from [get_cells pulse3_reg]        -to [get_cells pulse3_clk0_d_reg] 10.0
set_max_delay -datapath_only -from [get_cells pulse4_toggle_reg] -to [get_cells pulse4_clk0_d_reg] 4.5
set_max_delay -datapath_only -from [get_cells meta_data_reg]     -to [get_cells meta_a_reg]        4.5
set_max_delay -datapath_only -from [get_clocks {clk1 clk2 clk3 clk4 clk5 clk6 clkb}] \
                             -to   [get_cells ssd_sync_reg[*]] 10.0
```

- Prefer cell-level constraints for the synchronizers: a crossing the student forgets remains as a failing "Timed (unsafe)" path, so missing synchronizers are visible rather than hidden.
- Optionally name the generated clocks so reports are readable, e.g. `create_generated_clock -name clk3 [get_pins mmcm_main/CLKOUT3]`.
- Students should compute X from their actual clock periods and state which rule they used in the report.

**Alternative: `set_clock_groups -asynchronous`.**
- Declares groups of clocks unrelated: clocks in the same group are timed normally; clocks in different groups are not timed in either direction. Clocks not listed are unaffected.
- Like a false path between each pair of groups, but Vivado records the intent ("Asynchronous Groups" in `report_clock_interaction`), and `report_cdc` analyzes those crossings.
- Takes precedence over `set_max_delay`, so it cannot be combined with `-datapath_only` on the same clock pair, and it gives no bound on route length.
- Grouping should reflect how the design treats the crossings, e.g. `{clk0 clk1 clk2}` together (same frequency, fixed phases, would be timed correctly), and clk3, clk4, clkb, and `sys_clk_pin` in separate groups. Avoid `-include_generated_clocks` on `sys_clk_pin` (it pulls every clock into one group).

**Do not use `set_multicycle_path`** for these crossings: it assumes stable data and a known edge relationship.

### Proposed flow and requirements

1. Synchronizers use `ASYNC_REG` and a `set_max_delay -datapath_only` on the first stage.
2. The display register gets a `set_max_delay -datapath_only` from the counter clocks.
3. The metastability flop gets a tight `set_max_delay -datapath_only`.
4. Run `report_clock_interaction` before and after adding the constraints (before: "Timed (unsafe)" pairs; after: none). Good report screenshot or question.
5. Run `report_cdc -details -file cdc_mmcm_top.rpt` in the implement rule and add it to passoff's build files. Expected rule IDs (confirm in a trial run):

   | Crossing | Likely result | Student action |
   | --- | --- | --- |
   | PULSE3 / PULSE4 synchronizers | CDC-3 (Info: 1-bit synchronized with ASYNC_REG) | None |
   | Synchronizer missing ASYNC_REG | CDC-2 (Warning) | Fix |
   | Logic before a synchronizer | CDC-10 (Critical) | Fix (drive the crossing from a flop) |
   | Counter mux → display register | CDC-4 (multi-bit unknown), possibly CDC-12 (multi-clock fan-in) | Waive and justify |
   | Metastability circuit | CDC-1 (1-bit unknown) | Waive and justify |

6. Deliberately unsafe crossings get a `create_waiver` with a description, e.g.:
   ```tcl
   create_waiver -type CDC -id CDC-4 -from [get_cells cnt0_reg[*]] -to [get_cells ssd_sync_reg[*]] \
     -description "Display only; a sampling error lasts one display refresh"
   ```
7. Passoff/grading: no CDC-2 or CDC-10 entries, every Critical entry waived, positive WNS.
8. report.md questions: justify each waiver; explain why the clkb → clk0 requirement is ≈ 0.3 ns without constraints (requires computing the common period).

Optional teaching exercise: implement once with no CDC constraints, record the failing inter-clock paths and the "Timed (unsafe)" pairs, then add the constraints and compare.

### Open questions (resolve with a reference implementation)

- [x] Does `report_cdc` analyze crossings between *related* clocks that are only constrained with `set_max_delay -datapath_only`? *Resolved by a trial run (Vivado 2024.1):* yes. Counter → display crossings with a max delay showed as Critical / Unknown, the PULSE3 synchronizer as Info / Safe, and related-clock crossings with no exception as "Safely Timed" / Safe (timed synchronously, so no synchronizer is required). It definitely analyzes clocks declared with `set_clock_groups -asynchronous` and clocks with no common primary clock. If it skips the related pairs, there is a tradeoff (max delay: proper timing but a sparse CDC report; clock groups: complete CDC report but no timing). A truly unrelated clock (`CFGMCLK`, see Proposal 2) avoids the issue.
- [ ] Confirm the actual CDC rule IDs reported.
- [ ] Confirm `create_waiver` works from the XDC in the installed Vivado version.
- [ ] Confirm all inter-clock timing failures are gone.

## Proposal 2: Metastability measurement circuit

Related items above: "The metastability circuit depends entirely on XAPP094 Figure 1" and the report.md metastability question. This would replace the "Metastability Circuit" section of `mmcm.md`.

**Status:** implemented as a provided, stand-alone top-level design rather than a circuit students insert into their own design. Students build it with `metastability_build.tcl` (using their `seven_segment8` and `debounce` modules), run it on the board, and complete six exercises (reports, CFGMCLK frequency, the 50% point and zero point, the metastability margin, a two-point τ estimate, and synchronizer implications). Differences from the description below: the detector MMCM is fed directly from `CLK100MHZ`, four buttons control the phase (BTNU/BTND ±1 step, BTNL/BTNR ±8 steps, limited to 0–140 steps), the display shows decimal values, and LED[1] indicates when a measurement is valid. See Proposal 3 for possible extensions.

### Why students don't see metastability now

The current detector gives the sampling flop a full clock period or more to settle. A 7-series flop settles with a time constant τ of tens of ps (an estimate; AMD doesn't publish it), so the probability that it is still unresolved after ~4 ns is effectively zero. XAPP094 was designed for XC4000-era parts, which settled far more slowly. To see events, the flop output must be sampled **a few hundred ps** after the clock edge.

### Approach

- Use the STARTUPE2 internal configuration oscillator (`CFGMCLK`, nominally 65 MHz with a wide tolerance; check DS181) as a **truly asynchronous** data source. It is independent of the board oscillator, so data edges land at random points relative to the sampling clock.
- Use the MMCM **fine dynamic phase shift** to place a second sample a small, adjustable time Δ after the first. Each `PSEN` pulse shifts the output by 1/56 of the VCO period (≈ 18 ps at Fvco = 1000 MHz).
- Students sweep Δ and plot the error rate. The exponential tail of the curve is metastability.

### Why CFGMCLK rather than MMCM-related clocks for the data

A flop only goes metastable when the data edge lands inside a tiny window (a few ps at most) around the clock edge.

**MMCM-related data clocks.** All MMCM clocks are locked to the same crystal, so the data-to-clock phase follows a fixed, repeating pattern.
- Example: clkb → clk0 at 33:31. Over each 330 ns common period, data edges land at only ~31 distinct offsets, spaced ≈ 0.32 ns apart, repeating exactly forever.
- Jitter (tens of ps) moves each offset only slightly relative to the 320 ps spacing. Usually no offset falls near the window, so the count is zero (probably part of why students have seen nothing).
- If placement happens to put an offset right on the window, the count is large, but it reflects that build's routing, not the flop. A rebuild changes it.
- Larger M/D ratios or cascaded MMCMs give finer spacing, but are limited by the divider ranges, and the pattern never drifts.

**CFGMCLK data.** An independent on-chip oscillator whose frequency drifts with temperature and voltage. Over time the data edge lands at every offset with equal probability, which is what the standard MTBF model assumes:
```
event rate ≈ f_clk × f_data × T0 × e^(−t/τ)
```

| | MMCM-related data | CFGMCLK data |
| --- | --- | --- |
| Edge offsets covered | A fixed, repeating set (~ns spacing, smeared only by jitter) | All offsets, uniformly over time |
| Event count | Usually 0, or large and set by placement | Statistically meaningful |
| Repeatable between builds | No (depends on routing delay) | Yes (statistically) |
| Matches the MTBF model | No | Yes: the rate should scale with f_clk × f_data |
| Known, adjustable frequency | Yes | No (nominally 65 MHz, wide tolerance) |
| Exact simulation | Yes | No (use a testbench clock instead) |

**CFGMCLK drawbacks:**
- Unknown, fixed frequency. Students can measure it with a counter against `CLK100MHZ` (a good exercise).
- One `STARTUPE2` per design (conflicts with SPI flash access).
- Noisy. Fine for a data source (noise only helps spread the edges), but a reason not to feed it into an MMCM.

**MMCM-only alternative.** Put the data-source toggle on a separate MMCM output and pulse `PSEN` continuously on that output. A steadily moving phase is equivalent to a slightly different frequency, so the data edge sweeps through every offset in ~18 ps steps, with jitter filling in between.
- Pros: no `STARTUPE2`; the sweep rate is adjustable.
- Cons: a second dynamically shifted output (ideally on a separate MMCM so it doesn't move clk_b), more control logic, and coverage is uniform only while the shift runs steadily.

**Recommendation:** use `CFGMCLK` for the data source (simplest truly random edge timing, and results can be checked against the MTBF model). Use the MMCM for what it does well: the precisely controlled Δ between the two sampling clocks.

### Circuit

```
            CFGMCLK domain           clk_a (e.g., 200 MHz, MMCM CLKOUT0)
          ┌──────────┐         ┌───────┐
 CFGMCLK ─┤ toggle FF├─data───►│  A    │──┬───────────────────►┌───────┐
          └──────────┘         │(clk_a)│  │                    │  C    │ late sample
                               └───────┘  │                    │(clk_a)│ (full period:
                                          │   ┌───────┐        └───┬───┘  settled value)
                                          └──►│  B    │──►┌──────┐ │
                                              │(clk_b)│   │  B2  │ │
                                              └───────┘   │(clk_a)│ │
                                        early sample,     └──┬───┘ │
                                        Δ after clk_a edge   └─XOR─┴──► err (count it)
```

- **clk_a**: fixed MMCM output (e.g., 200 MHz).
- **clk_b**: same frequency from the same `MMCME2_ADV`, with `CLKOUT1_USE_FINE_PS = "TRUE"` (requires `MMCME2_ADV`, not `MMCME2_BASE`).
- **A** samples the asynchronous data; this is the flop that goes metastable.
- **B** samples A only Δ after the clk_a edge (short settling time).
- **C** samples A one full clk_a period later (settled, "true" value).
- **B2** moves B's sample into the clk_a domain, aligned with C (both refer to the same clk_a edge).
- `err = B2 ^ C` means A had not settled within Δ. `trans` counts A transitions for normalization.

```systemverilog
// CFGMCLK domain: asynchronous data source
always_ff @(posedge clk_cfg) data_tog <= ~data_tog;

(* DONT_TOUCH = "TRUE" *) logic ff_a, ff_b, ff_c, ff_b2;
always_ff @(posedge clk_a) ff_a <= data_tog;   // may go metastable
always_ff @(posedge clk_b) ff_b <= ff_a;       // early sample: Δ after the clk_a edge
always_ff @(posedge clk_a) begin
  ff_c   <= ff_a;                              // late sample: settled value
  ff_b2  <= ff_b;                              // early sample, brought into clk_a
  ff_c_d <= ff_c;
  err    <= ff_b2 ^ ff_c;                      // A had not settled within Δ
  trans  <= ff_c ^ ff_c_d;                     // A changed value (normalization)
end
```

STARTUPE2 instance:
```systemverilog
STARTUPE2 startup_inst (
  .CFGMCLK(cfgmclk_raw),   // internal ~65 MHz oscillator
  .CFGCLK(), .EOS(), .PREQ(),
  .CLK(1'b0), .GSR(1'b0), .GTS(1'b0), .KEYCLEARB(1'b1),
  .PACK(1'b0), .USRCCLKO(1'b0), .USRCCLKTS(1'b0),
  .USRDONEO(1'b1), .USRDONETS(1'b1)
);
BUFG cfg_bufg (.I(cfgmclk_raw), .O(clk_cfg));
```

### Expected result

```
err/trans
  1.0 ┤████████╗                         Δ too small: B always misses the new
      │        ║                         value (normal delay, not metastability)
      │        ╚╗
      │         ╚═╗                      Edge: blurred by clock jitter
      │           ╚══╗
      │              ╚═══╗___            Tail: A was metastable and settled late
  0   ┼──────────────────────╚════──►  Δ
           ~Tco + route + setup
```

- **Plateau**: ordinary delay; B samples before A's output can arrive.
- **Edge**: the normal delay (≈ 0.5–1 ns, depending on placement), blurred by jitter between the two clocks.
- **Tail**: metastability. On a log scale it should be roughly linear, `ln(err/trans) ∝ −Δ/τ`, so students can estimate τ.
- Separating the exponential tail from the jitter-blurred edge is the hard part, and a good report question.

### Measurement and control (reuses earlier lab modules)

- **Phase control**: BTNU / BTND (debouncer + one-shot) issue one `PSEN` pulse each with `PSINCDEC` = 1 or 0. `PSCLK` can be `CLK100MHZ`. Wait for `PSDONE` before the next step. Keep a signed phase-step counter.
- **One-second counts**: count `err` and `trans` in the clk_a domain for 200,000,000 cycles, then save both and clear. The saved values change once per second (quasi-static crossing); move them to the display domain with a toggle handshake + synchronizer (another small CDC exercise).
- **Display**: switches select the phase step, error count, or transition count.
- **Optional automatic sweep**: a state machine steps the phase once per second and sends `step, trans, err` over the UART transmitter from the earlier lab. Students log a CSV and plot/fit τ.

### Placement and constraints

- **Fixed placement**: A, C, and B2 in one slice; B in the other slice of the same CLB (`LOC` / `BEL`). All flops in a slice share a clock, so B (clk_b) can't share A's slice. Fixed placement makes the edge position repeatable between builds.
- **`DONT_TOUCH`** on the detector flops so Vivado doesn't merge, replicate, or optimize them.
- **CFGMCLK**: `create_clock -name clk_cfg -period 15.385 [get_pins startup_inst/CFGMCLK]`, plus `set_clock_groups -asynchronous` against the other clocks. Vivado still times unrelated clocks by default ("Timed (unsafe)"), so students must add this. Because `CFGMCLK` shares no primary clock with `sys_clk_pin`, `report_cdc` should treat it as asynchronous.
- **A → B**: `set_max_delay -datapath_only 1.0`. This path deliberately violates timing; the bound keeps it short, and its timing report shows the actual Tco + route, which students can compare with the edge position in their sweep.
- **B → B2**: Vivado only knows clk_b's static phase, not the dynamic shift. Bound it with `-datapath_only` to the period minus the largest Δ (e.g., 2–3 ns).

### Simulation

RTL simulation never shows metastability. Test the logic (counting, phase-step control, handshake) with a testbench-generated asynchronous clock in place of `CFGMCLK` (the STARTUPE2 model may not toggle `CFGMCLK`), selected with a top-level parameter:
```systemverilog
initial begin
  clk_async = 0;
  #($urandom_range(0, 15000) * 1ps);           // random start phase
  forever #(7.6923ns + ($urandom_range(0,40)-20)*1ps) clk_async = ~clk_async; // ~65 MHz with jitter
end
```

### Caveats and open questions

- [ ] **Event rate is unknown.** AMD doesn't publish 7-series metastability parameters, and `report_synchronizer_mtbf` only supports UltraScale. A reference build is essential to confirm the edge position and that the tail is visible above the jitter.
- [ ] **Undercounting.** If A goes metastable and settles to the *old* value, B and C agree and nothing is counted. Fine for estimating τ (the slope matters, not the absolute count).
- [ ] **STARTUPE2 conflict.** Only one per design; it would conflict with any lab that uses the SPI flash clock (`USRCCLKO`).
- [ ] **`CFGMCLK` into an MMCM** is not recommended (noisy; may not lock reliably). Use it directly through a BUFG.
- [x] **Scope.** This adds `MMCME2_ADV` dynamic phase shift, STARTUPE2, placement constraints, and a measurement/handshake circuit. Decide whether it replaces the current metastability section, becomes a separate lab, or is an optional extension. *Resolved:* provided as a stand-alone design that students build and run.

## Proposal 3: Extending the metastability experiment

The current exercises were deliberately kept simple (no plotting, a two-point τ estimate). The ideas below would make the experiment more thorough. They are listed roughly from easiest to hardest. All of them should be tried on a reference build first: the actual τ, the edge location, and whether the tail is visible above the clock jitter are still unknown.

### Background model (for writing the extensions)

- Error ratio r(Δ) = errors / transitions. Let t<sub>d</sub> be the normal delay seen by B (clock-to-Q + route + setup + clk_b/clk_a skew), and T<sub>a</sub> = 5 ns (the clk_a period).
- Plateau (Δ < t<sub>d</sub>): r ≈ 1.
- Tail (Δ > t<sub>d</sub>): r(Δ) ≈ (T<sub>0</sub> / T<sub>a</sub>) · e<sup>-(Δ - t<sub>d</sub>)/τ</sup>, so ln r is a straight line with slope -1/τ. T<sub>0</sub> (the metastability window) is probably a few ps or less, so the tail starts around 10<sup>-3</sup>.
- Edge: clock jitter (tens of ps) blurs the step from 1 to T<sub>0</sub>/T<sub>a</sub>. On a log scale the edge curves downward more and more steeply (jitter falls off faster than an exponential); the tail is straight.
- The first zero point is where the expected count in the measurement window drops below about one. It depends on the measurement time, not just the flip-flop.

### Extensions

- [ ] **Full sweep and plot.** Record every fine step from below the edge to the zero point (in a CSV file) and plot ln(errors/transitions), or the ratio on a log axis, against Δ. Have students label the plateau, edge, and tail, and explain why the edge curves while the tail is straight. Leave out zero counts (they can't be plotted on a log scale).
- [ ] **Least-squares fit for τ.** Fit a line to ln(r) against Δ over the tail only and report τ = -1/slope. Points to discuss:
  - Exclude the edge (if the "tail" still curves, the fit is measuring jitter, not τ).
  - Exclude zero counts and down-weight small counts: counting noise is about √N, so a count of 4 could easily have been 2 or 6. A weighted fit with weights proportional to N (the inverse variance of ln N) is the proper approach.
  - Report the uncertainty of τ from the fit and compare it with the two-point estimate.
- [ ] **Step-to-step ratio.** In the tail, the count should drop by a roughly constant factor per fine step (for τ ≈ 20–25 ps, about 0.4–0.5 per 17.9 ps step). A constant ratio is the signature of exponential decay; a ratio that changes from step to step indicates the edge. This gives a quick τ = 17.9 ps / ln(N<sub>1</sub>/N<sub>2</sub>) at every step.
- [ ] **Repeatability (counting statistics).** Record five measurements at one Δ in the tail and compare the spread with √N. (This was exercise 7 in an earlier draft.)
- [ ] **Measurement time and the zero point.** At Δ<sub>0</sub>, record ten consecutive measurements (a 10 s window); a few errors will probably appear. Then find the Δ where ten consecutive measurements are all zero. Watching 10× longer should move the zero point by about τ·ln(10) ≈ 2.3τ (about 50 ps, three fine steps). This demonstrates that "no errors" only means "no errors yet", which is the MTBF concept.
- [ ] **MTBF extrapolation.** At Δ<sub>0</sub> the circuit fails about once per second. Each additional τ·ln(10) of settling time reduces the failure rate 10× (and each τ·ln(2) ≈ 15 ps halves it). Have students compute the additional settling time for one failure per day (≈ 11.4τ), per year (≈ 17.3τ), and per age of the universe (≈ 40τ, under 1 ns for τ ≈ 22 ps), and compare with the ~9 ns a two flip-flop synchronizer at 100 MHz provides (over 100 orders of magnitude of margin). Treat the results as order-of-magnitude estimates.
- [ ] **Errors per transition.** Express tail measurements as odds (e.g., 650 errors out of 65 million transitions is 1 in 100,000) to make the probabilities concrete.
- [ ] **Estimate T<sub>0</sub>.** Using the fitted line and Δ<sub>50</sub> as the estimate of t<sub>d</sub>, extrapolate the tail back to Δ = t<sub>d</sub>: the intercept is T<sub>0</sub>/T<sub>a</sub>. Sensitive to the t<sub>d</sub> estimate (an error of δ in t<sub>d</sub> scales T<sub>0</sub> by e<sup>δ/τ</sup>), so treat it as rough.
- [ ] **Compare Δ<sub>50</sub> with the timing model.** The `-datapath_only` constraint hides the clock paths in the A → B timing report. In the opened checkpoint, remove the exception (`reset_path -from [get_cells ff_a_reg] -to [get_cells ff_b_reg]`; confirm the command) and rerun `report_timing` to see clock-to-Q, route, setup, and the clk_a/clk_b skew at Δ = 0. Compare Δ<sub>50</sub> with both the slow corner (default) and fast corner (`-delay_type min`) results. The measured value should fall between them, since a real chip at room temperature is faster than the worst-case model.
- [ ] **Data rate scaling.** The error rate should be proportional to f<sub>clk</sub> × f<sub>data</sub>. Add a switch that makes `data_tog` toggle every 2 or 4 `CFGMCLK` cycles; at a fixed Δ in the tail, the error count should drop by 2× or 4× while the error ratio (errors per transition) stays the same. This checks the MTBF formula directly with a small design change.
- [ ] **Placement experiment.** Build with the pblock moved, or with the A → B route made longer. The edge (t<sub>d</sub>) should move while τ stays the same, showing that t<sub>d</sub> depends on the implementation and τ is a property of the flip-flop.
- [ ] **Temperature.** `CFGMCLK` (the transition count) and possibly τ change with temperature. Comparing a cold board with a warm one is easy to observe, but avoid touching the FPGA (ESD).
- [ ] **Automatic sweep over the UART.** Add a mode that steps Δ once every two measurements and sends `step, transitions, errors` over the UART transmitter from the earlier lab. Students log a CSV with a terminal program or Python, which removes manual recording, makes the full sweep and the least-squares fit practical, and allows longer measurement windows (e.g., 10 s per point) for the tail.
- [ ] **Display the error ratio directly.** Add a sequential divider to show errors per million transitions (ppm), so students don't have to compute ratios by hand.
- [ ] **Longer measurement window.** Make `GATE_CYCLES` selectable (e.g., 1 s or 10 s with a switch) to resolve the far tail with more counts, at the cost of a slower sweep.

### Caveats for any extension

- **Jitter may hide the tail.** If the count drops straight from the edge to zero, the "tail" measurements really measure jitter, and τ cannot be extracted. The margin and zero-point exercises still work.
- **Undercounting.** If A goes metastable and settles to the old value, B and C agree and the event isn't counted. This affects T<sub>0</sub> estimates but not τ (the slope).
- **B → B2 limit.** Near the 2.5 ns maximum Δ, the B → B2 path runs out of time and errors could reappear. This is an artifact of the circuit, not metastability.

## Proposal 4: Add a truly asynchronous clock (CFGMCLK) to the student design

**Status:** future semester. It is too late to change the student design for Fall 2026.

### Motivation

- Every clock in the current student design comes from `CLK100MHZ` (the secondary MMCM uses CLKOUT0 as its input). Vivado treats all of them as related, so:
  - unconstrained crossings fail timing with meaningless requirements (e.g., ≈ 0.3 ns for CLKB → CLKOUT0);
  - `report_cdc` reports related crossings without exceptions as "Safely Timed" / Safe, even when they have no synchronizer;
  - on the board, data-to-clock phase follows a fixed, repeating pattern, so a broken synchronizer may fail consistently or never, depending on placement.
- `CFGMCLK` (the STARTUPE2 internal configuration oscillator, nominally 65 MHz) is independent of the board oscillator. It is a real asynchronous clock domain:
  - Vivado sees no common primary clock, and `report_cdc` analyzes the crossings as "No Common Primary Clock";
  - the phase relative to the other clocks drifts continuously, so crossing bugs show up on the board as intermittent failures, like real designs;
  - students already use this clock in the provided metastability design, so the primitive and constraints will be familiar.

### Suggested changes to the student design

- [ ] Instance `STARTUPE2` and a BUFG for `CFGMCLK` in `mmcm_top` (instantiation and constraints can be copied from `metastability_top.sv` / `metastability_top.xdc`). Add `create_clock -name clk_cfg -period 15.385 [get_pins <startup_inst>/CFGMCLK]`.
- [ ] Have students observe that Vivado still times crossings between unrelated clocks by default ("Timed (unsafe)" in `report_clock_interaction`), so they must add `set_max_delay -datapath_only` constraints. This teaches that Vivado assumes all clocks are related unless told otherwise.
- [ ] Move one or more of the clock domain crossing exercises to this clock. Options:
  - **Frequency counter:** count `CFGMCLK` cycles for one second of `CLK100MHZ` and display the result. This requires a multi-bit crossing (e.g., a toggle handshake like the one in `metastability_top.sv`, or a gray-code counter with `set_bus_skew`), and each board reads slightly differently.
  - **Pulse crossings:** generate PULSE3-style (slow → fast) or PULSE4-style (fast → slow) pulses in or out of the `CFGMCLK` domain, so the synchronizers are exercised with truly random phase.
  - **Counter display:** add a 48-bit `CFGMCLK` counter to the display mux (another unsafe display crossing to waive).
- [ ] Add report questions on the `report_cdc` results for the `CFGMCLK` crossings, and compare them with the MMCM crossings ("No Common Primary Clock" vs "Safely Timed").
- [ ] Consider making `CFGMCLK` the asynchronous clock for all CDC exercises and keeping the MMCM clocks for the frequency, phase, and duty cycle portion of the lab.

### Caveats

- **Simulation:** the STARTUPE2 simulation model may not toggle `CFGMCLK`. Have the testbench supply the clock instead (e.g., a top-level parameter that selects a testbench clock with a random start phase and jitter).
- **Unknown frequency:** nominally 65 MHz with a wide tolerance (check DS181). Exercises must not depend on an exact frequency; the measured frequency in the metastability experiment was about 65 MHz.
- **One STARTUPE2 per design:** it conflicts with any design that needs the SPI flash clock (`USRCCLKO`). Not an issue for `mmcm_top`.
- **Do not use `CFGMCLK` as an MMCM input:** it is noisy and the MMCM may not lock reliably. Use it directly through a BUFG.
- **Grading:** the constraints and waivers become part of the grading criteria (every `CFGMCLK` crossing should appear in `report_cdc` as Safe, or waived with a justification).
