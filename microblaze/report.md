# MicroBlaze Assignment

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

  1. **Resource utilization.** Complete the table below from the hierarchical utilization report of your implemented `mb_uart` design (see the [instructions](./microblaze.md#submission-and-grading) for generating this report). The "Total" row is the whole design; the other rows are the MicroBlaze processor block and your `uart_axi` block.

| Instance | Slice LUTs | Slice Registers | Block RAM Tile | DSPs |
| ---- | ---- | ---- | ---- | ---- |
| Total |  |  |  |  |
| MicroBlaze (`microblaze_0`) |  |  |  |  |
| Your UART (`uart_axi`) |  |  |  |  |

  What fraction of the LUTs in the design does the MicroBlaze use? What fraction does your `uart_axi` use?

  2. **Address map.** Complete the table below from the "Address Editor" tab of your `mb_uart` block diagram. Each `XPAR_*_BASEADDR` constant used by `mb_uart.c` comes from this address map.

| Peripheral | Base Address | Range |
| ---- | ---- | ---- |
| axi_gpio_LED |  |  |
| axi_gpio_SW |  |  |
| axi_gpio_BTN |  |  |
| axi_gpio_SSD |  |  |
| uart_axi |  |  |

  3. **Custom application.** Describe what your custom application (`custom.c`) does and how to use it: what the buttons and switches do, what to type in the terminal (and the terminal settings), and what appears on the LEDs, the seven segment display, and the terminal.

  4. **Block diagram.** Make sure the screenshot of your `mb_uart` block diagram [`mb_uart_bd.png`](./mb_uart_bd.png) is committed to your repository so it can be viewed in this report.

![mb_uart block diagram](./mb_uart_bd.png)