# UART Receiver Simulation

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
  1. Fill in the State Machine Encoding table listed [below](#state-machine-encoding) for both the default synthesis and your gray code encoding
  2. Fill in the Resource Utilization table listed [below](#resource-utilization-table) for both the default and gray code synthesis
  3. Provide a detailed list of steps that the testbench follows to test your receiver. Consult the [testbench](./tb_rx.sv) for details. You can use a bulleted list or a numbered list.
  4. Summarize the purpose of each 'task' in the testbench.

### State Machine Encoding

**Default Encoding**
| State | Encoding |
| ---- | ---- |
| IDLE   | '00000' |

**Gray-code Encoding**
| State | Encoding |
| ---- | ---- |
| IDLE   | '00000' |


### Resource Utilization Table

**Default Encoding**
| Resource | Utilization |
| ---- | ---- |
| CARRY4 |  |
| LUTx   |  |
| FDxx   |  |

**Gray Code Encoding**
| Resource | Utilization |
| ---- | ---- |
| CARRY4 |  |
| LUTx   |  |
| FDxx   |  |

(For LUTx, add up the total number of LUTs of all sizes)