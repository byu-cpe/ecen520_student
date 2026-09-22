# UART Transmitter/Receiver Synthesis and Download

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
  1. Fill in the State Machine Encoding table listed [below](#state-machine-encoding)
  2. Fill in the Resource Utilization table listed [below](#resource-utilization-table)
  3. Review the timing report (`timing.rpt`) and summarize the following:
       * Determine the "Worst Negative Slack" (or WNS). 
       * Summarize the `no_input_delay` and `no_output_delay` section of the report.
       * How many total endpoints are there on your clock signal?
       * Find the first net in the `Max Delay Paths` section and indicate the source and destination of this maximum path. 
  4. Indicate how many times you had to download your bitstream before your circuit worked. Note that I want two numbers: number of synthesis attempts (X) and number of download attempts (Y). Do not mix these together. **X/Y**

### State Machine Encoding

Provide a table summarizing _each_ state machine encoding used in your design.
If you have more than one state machine, provide a separate table for each state machine.

| State | Encoding |
| ---- | ---- |
| IDLE   | '00000' |

### Resource Utilization Table

| Resource | Utilization |
| ---- | ---- |
| BUFG   |  |
| CARRY4 |  |
| LUTx   |  |
| FDRE   |  |
| IBUF   |  |
| OBUF   |  |

(For LUTx, add up the total number of LUTs of all sizes)