# MMCM Assignment

**Name**: Your Name<br>
**Hours Spent**: # hrs<br>

## Summarize any major challenges you had completing this assignment
* Challenge 1 (Submit at least one challenge for your assignment report)
* Challenge 2 (If you don't have a second challenge, remove this bullet)

## Use of AI

Describe how you used AI for this assignment (indicate none if applicable).
See the class [AI policy](../ai_policy.md) for a summary of acceptable use.

## Provide suggestions for improving this assignment (optional)
  * Suggestion 1 (List 'None' for the bullet item if you are not providing suggestions)

## Assignment Specific Responses
  1. How many times did you synthesize your design? **X**
  2. Indicate the location of your two MMCMs:
    * Main MMCM: **MMCME2_ADV_XxYx**
    * Secondary MMCM: **MMCME2_ADV_XxYx**
  3. Make sure you have the following files committed to your repository so they can be viewed in this report:
      * [`mmcm_clk0.png`](./mmcm_clk0.png)
      * [`mmcm_clk1.png`](./mmcm_clk1.png)
      * [`mmcm_clk2.png`](./mmcm_clk2.png)
      * [`mmcm_clk3.png`](./mmcm_clk3.png)
      * [`mmcm_clk4.png`](./mmcm_clk4.png)
      * [`mmcm_clk5.png`](./mmcm_clk5.png)
      * [`mmcm_clk6.png`](./mmcm_clk6.png)
  4. Timing Report Review
    * What is the "Worst Negative Slack" (WNS) of this design?: **X.Xns**
    * Which clock domain has the worst timing?: **<clock name>**
    * How many "THS Total Endpoints" are there for this design? **X**
    * Complete the Clock Domain Timing Table listed [below](#clock-domain-timing-table) using your MMCM settings and your implementation timing report.
  5. Complete the Utilization Report table listed [below](#utilization-report-table) from your implementation utilization report.
  6. How many times did you have to download your design to the Nexys4 board before it worked correctly? **X**
  7. Complete the [Metastability Experiment](#metastability-experiment) questions below.

### Metastability Experiment

  1. Review the reports:
    * Does the design meet timing? **Yes/No**
    * Data path delay from flip-flop A to flip-flop B: **X.XXX ns**
    * Which crossings are waived in the CDC report, and why is it acceptable to waive them?
  2. CFGMCLK frequency:
    * Five transition counts: **X, X, X, X, X**
    * Average frequency: **XX.XXX MHz**
    * Variation between measurements and comparison to the nominal 65 MHz:
  3. 50% point and zero point:
    * Last step with ratio above 0.5: Δ<sub>1</sub> = **XXX ps**, r<sub>1</sub> = **X.XX**
    * Next step (ratio below 0.5): Δ<sub>2</sub> = **XXX ps**, r<sub>2</sub> = **X.XX**
    * Δ<sub>50</sub> = **XXX ps**
    * How does Δ<sub>50</sub> compare with the data path delay from question 1?
    * Δ<sub>0</sub> = **XXX ps**
  4. Metastability margin (Δ<sub>0</sub> - Δ<sub>50</sub>): **XXX ps**. How does it compare to a 10 ns clock period?
  5. Estimate of τ:
    * Δ<sub>A</sub> = **XXX ps**, N<sub>A</sub> = **X**
    * Δ<sub>B</sub> = **XXX ps**, N<sub>B</sub> = **X**
    * τ = **XX ps**
  6. Factor by which the probability of an unsettled flip-flop drops for each additional 1 ns of settling time: **X**. Explain why a two flip-flop synchronizer clocked at 100 MHz almost never fails, and why a detector that gives the flip-flop a full clock period to settle will almost never detect an event.

### Clock Domain Timing Table

For each clock, list the MMCM settings you used: the multiply (M, `CLKFBOUT_MULT_F`) and divide (D, `DIVCLK_DIVIDE`) values of the MMCM, and the output divide (O, `CLKOUTn_DIVIDE`) of the clock.
The phase is relative to the input clock. Enter "n/a" for the phase of CLKB, since that MMCM does not deskew its output (it has no defined phase relationship with its input).
The setup and hold slack values are the worst slack for each clock domain in your timing report.

| Clock Domain | M / D / O | Frequency | Period | Phase | Setup Slack | Hold Slack |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Input Clock | n/a | 100 MHz | 10.00 ns | 0° | | |
| CLKOUT0 |  |  |  |  |  |  |
| CLKOUT1 |  |  |  |  |  |  |
| CLKOUT2 |  |  |  |  |  |  |
| CLKOUT3 |  |  |  |  |  |  |
| CLKOUT4 |  |  |  |  |  |  |
| CLKOUT5 |  |  |  |  |  |  |
| CLKOUT6 |  |  |  |  |  |  |
| CLKB (secondary MMCM) |  |  |  |  |  |  |

### Utilization Report Table

See the "Primitives" section of your utilization report for the values to fill in the table below.

| Resource | Utilization |
| ---- | ---- |
| BUFG   |  |
| CARRY4 |  |
| MUXF7 |  |
| LUTx   |  |
| FDxE   |  |
| IBUF   |  |
| OBUF   |  |
| MMCME2_ADV   |  |
