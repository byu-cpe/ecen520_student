# BRAM Assignment: Pending Changes

Review notes for `bram.md`, `passoff.py`, `report.md`, and `gen_readmem.py`.
Line numbers refer to `bram.md` at the time of review and may have shifted.

## Mismatches between bram.md, passoff.py, and report.md

- [x] **Report questions disagree.**
  - `bram.md` (Submission item 3) asks for one combined "Cell Type | BRAM ROM | BRAM FIFO" table.
  - `report.md` has two separate tables, plus an `INIT_00` question that `bram.md` doesn't mention.
  - Pick one format and delete the other. The `INIT_00` question is worth keeping.
  - `report.md` item 2 (ROM) says "synthesis report for your FIFO design" (copy-paste error).
  - *Resolved:* removed the combined table from `bram.md`. Submission item 2 now summarizes the report.md questions (two utilization tables plus `INIT_00`). Fixed the "FIFO design" copy-paste error in report.md item 2.
- [ ] **passoff doesn't check that `modelsim.ini` is committed,** though `bram.md` requires it.
  - Add `tester.add_required_tracked_files(["modelsim.ini"])`.
- [ ] **No simulation log is checked for failures.**
  - Require the testbenches to print `Error:<bram_fifo_tb>` / `Error:<bram_rom_tb>` on a mismatch.
  - Add a `repo_test.file_regex_check(..., error_on_match = True)` for each log, as in spi_cntrl.
  - The FIFO testbench already compares against a queue, so it's a natural fit.
- [x] **The .mem files aren't explained.**
  - passoff expects `fight_song.mem` and `moroni_10.mem` as *build outputs* of the sim rules.
  - `bram.md` never says the makefile should generate them with `gen_readmem.py`, or that they shouldn't be committed.
  - `synth_bram_rom` also needs `fight_song.mem`, but on a clean checkout nothing generates it unless that rule does. Have the rule depend on or generate the .mem file, and say so in the md.
  - *Resolved:*
    - The ROM Testbench section of `bram.md` now says the `.mem` files are generated (not committed, gitignored, removed by `clean`), and gives an example makefile rule using `gen_readmem.py`.
    - Students must make every sim and synth rule that uses a `.mem` file depend on it; the ROM Synthesis section repeats this for `synth_bram_rom`.
    - `passoff.py` now also expects `fight_song.mem` as a build output of `synth_bram_rom`.

## FIFO technical gaps

- [x] **Define `dout` timing.**
  - The BRAM read is synchronous (1-cycle latency).
  - After a write to an empty FIFO, `empty` drops a cycle before the right data appears on `dout`. After a read, `dout` lags the pointer by one cycle.
  - Specify the intended behavior: `dout` valid whenever `empty` is low (first-word fall-through), or valid one cycle after `re`.
  - *Resolved:* chose one-cycle read latency (not first-word fall-through).
    - The BRAM read port is enabled only on a valid read (`ENBWREN = re && !empty`), so `dout` shows the head byte the cycle after `re` and holds it until the next read. This avoids the stale-`dout` and write-to-empty problems.
    - Replaced "read from the memory every clock cycle" in `bram.md`, added `ENBWREN` to the list of ports to connect, and told the testbench to check `dout` the cycle after `re`.
- [ ] **Simulation library setup:**
  - The `RAMB36E1` model needs `glbl`. The comment note says so, but the active text doesn't. Students hit "glbl not found" unless they add `glbl` to the `vsim` command (and compile `glbl.v` if the library doesn't contain it).
  - Check whether the path should be `unisims_ver` (Verilog models) rather than `unisim` (VHDL library).
  - The hard-coded `/tools/Xilinx/Vivado/2024.1/...` path in a committed `modelsim.ini` conflicts with the "don't hard code paths" note. Consider an env variable such as `$XILINX_VIVADO/data/questa/unisims_ver`.
- [x] **Full/empty corner cases:**
  - Change "write address is one less than the read address" to `(wr_addr + 1) mod 4096 == rd_addr`, so it's clear it wraps. Mention that capacity is 4095.
  - Say what happens on a simultaneous `we` and `re` when full or empty.
  - State the address width (12 bits).
  - *Resolved:* `bram.md` now specifies 12-bit counters, `full` as `wr_addr + 1 == rd_addr` (12-bit wrap), a 4095-byte capacity, and the simultaneous `we`/`re` behavior (both occur normally; only the write when empty; only the read when full).
- [ ] **More RAMB36E1 hints** (requested in student feedback):
  - In x9 mode, all four `WEA` bits are driven by `we`.
  - `WEBWE` (8 bits) is tied to 0.
  - The address goes in `ADDR[14:3]` with the low bits at 0. Point to the "Port Address Mapping" table in UG473.
  - Cite the table name rather than "see page 25"; the docs.amd.com link may not keep that page number.
- [x] Typo: "Your FIFO should be created by as follows". *Resolved.*

## ROM technical gaps

- [ ] **Ask for a synchronous read.** An asynchronous read of the inferred array gives a LUT ROM, not a RAMB36E1, and the "one RAMB36E1" check then fails. Add: "register `dout` (read inside `always_ff`) so the memory is inferred as a BRAM."
- [ ] **`rst` vs `init`:** both reset the pointer. Say how they differ (e.g. `rst` also clears the output register) or drop one.
- [ ] **`rom_end` timing:** "when the value of the memory output is zero" lags the pointer by one cycle. Say whether `rom_end` is registered or combinational from `dout`.
- [ ] **`FILENAME` default:** give one (`"fight_song.mem"`). bram_download expects that default.
- [ ] **`moroni_10.txt` doesn't fit.** It is 6013 bytes and is cut off at 4095 characters (confirmed). Mention the truncation, or trim the file.

## Leftover wording

- [x] ROM Synthesis section: "After verifying that your FIFO works properly" should say ROM. *Resolved.*
- [x] Both synthesis sections: "before proceeding with the next module", but there is no next module after the ROM. *Resolved:* the ROM section now says "before submitting your assignment"; the FIFO section is correct as is (the ROM is the next module).
- [x] Missing space in "`bram_rom_tb.sv`that". *Resolved.*
- [x] The `FILENAME` parameter is described both in the table and again in the bullet list ("Provide a parameter..."). *Resolved:* the bullet now just says to use `FILENAME` in an initial block with `$readmemh`.
- [x] Submission list is numbered 1, 2, (blank line), 3, and the table renders outside the list. *Resolved* along with the report-questions item (item 3 and its table were removed).

## gen_readmem.py (latent bug)

- [x] **The `-r` length check can be skipped.**
  - With `-r`, a `\n` landing at position `length-2` writes `\n\r`. The `values == args.length-1` check is then skipped, and the script writes past `length` with no terminating zero.
  - The three provided files don't trigger it (each produces exactly 4096 entries), but another text file could.
  - Fix: change the check to `values >= args.length-1`.
  - *Resolved:*
    - Changing to `>=` alone would still write the zero as entry `length+1`, so the `\r` is now added only when there is room for it and the terminating zero (`values < args.length-1`). The check also uses `>=` as a safeguard.
    - Tested: a crafted edge case now produces exactly `length` entries ending in 0 (the old script produced 11 of 8, with no terminator). The fight song, Moroni 10, and Declaration of Independence outputs are byte-for-byte identical to before (apart from the header comment).

## Optional

- [ ] Consider merging this lab with bram_download, with the primitive hookup spelled out (student feedback: "Easy lab. Could be combined with download").
- [ ] Keep `rom_end` as a top-level port of `bram_rom`. bram_download feedback asks for it to be brought out.
