# BRAM Download Assignment

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
  2. Timing Report Review
    * What is the "Worst Negative Slack" (WNS) of this design?: **X.Xns**
    * How many "THS Total Endpoints" are there for this design? **X**
    * What is the "Source" netname of the "Max Delay Paths" worst case net? **<netname>>**
    * What is the "Destination" netname of the "Max Delay Paths" worst case net? **<netname>>**
    * What is the "Source" netname of the "Min Delay Paths" worst case net? **<netname>>**
    * What is the "Destination" netname of the "Min Delay Paths" worst case net? **<netname>>**
    * Summarize the `no_input_delay` and `no_output_delay` section of the report: (i.e., list number of ports in each of the sections and any other observations)
  3. What is the location of both BRAMs used in your design? (RAMB36_XxYx where 'x' is a number) **RAMB36_XxYx, RAMB36_XxYx**
  4. Your FIFO uses an instanced `RAMB36E1` primitive, while your ROM uses an inferred memory. How did you confirm from your synthesis log that the ROM memory was implemented as a `RAMB36E1` (and not as LUTs)? Copy the relevant line(s) from the synthesis log here.
  5. Describe how your design handles button presses when the UART transmitter is shared between the ROM and FIFO sends (e.g., what happens if the right button is pressed while the ROM is being sent, and vice versa).
  6. Complete the Utilization Report table listed [below](#utilization-report-table) from your implementation utilization report.
  7. How many times did you have to download your design to the Nexys4 board before it worked correctly? **X**

### Utilization Report Table

See the "Primitives" section of your utilization report for the values to fill in the table below.

| Resource | Utilization |
| ---- | ---- |
| BUFG   |  |
| CARRY4 |  |
| LUTx   |  |
| FDxE   |  |
| IBUF   |  |
| OBUF   |  |
| RAMB36E1   |  |
