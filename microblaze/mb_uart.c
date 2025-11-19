// mb_uart_test.c for the mb_uart MicroBlaze project

#include "xparameters.h"
#include "xgpio.h"
#define CHANNEL_1 1
#define CHANNEL_2 2

// Buttons Mask
#define BTNC 0x1
#define BTNU 0x2
#define BTNL 0x4
#define BTNR 0x8
#define BTND 0x10

// AXI UART constants
#define UART_TX_BASEADDRESS
#define UART_RX_BASEADDRESS
#define UART_CONTROL_BASEADDRESS
#define UART_STATUS_BASEADDRESS

#define RX_EMPTY_MASK 0x10

//#include "xil_io.h"
//Xil_In32((BaseAddress) + (RegOffset))
//Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))


/*
| Address Offset | Read | Write |
| ---- | ---- | ---- |
| 0x00 | RX Data | TX Data |
| 0x04 | Status Register (read only) | Control Register (write only)

* Reads to address offset 0x00 return a byte from the receiver FIFO. 
* Writes to address offset 0x00 write a byte to the transmit FIFO.
* Reads to address offset 0x04 return the value of status register (described below)
* Writes to address offset 0x04 write the value of the control register (described below)

**Status Register**
| Bit | Purpose |
| ---- | ---- |
| 0 | TX Busy |
| 1 | RX Busy |
| 2 | RX error status |
| 3 | TX FIFO full |
| 4 | RX FIFO empty |
| 5 | TX overflow |
| 6 | RX underflow |

**Control Register**
| Bit | Purpose |
| ---- | ---- |
| 0 | Clear TX FIFO |
| 1 | Clear RX FIFO |
*/

int main() {

    XGpio LED_gpio = {0};
    XGpio SW_gpio = {0};
    XGpio BTN_gpio = {0};
    XGpio SSD_gpio = {0};
    // Intialize the data structures for the devices. Use the base address as found
    // in the xparameters.h
    XGpio_Initialize(&LED_gpio, XPAR_AXI_GPIO_LED_BASEADDR);
    XGpio_Initialize(&SW_gpio, XPAR_AXI_GPIO_SW_BASEADDR);
    XGpio_Initialize(&BTN_gpio, XPAR_AXI_GPIO_BTN_BASEADDR);
    XGpio_Initialize(&SSD_gpio, XPAR_AXI_GPIO_SSD_BASEADDR);
    unsigned int switches, leds;
    unsigned int buttons;
    unsigned int seven_segment_value = 0;
    unsigned int uart_status;

    // Initialize the seven segment display with zero
    XGpio_DiscreteWrite(&SSD_gpio, CHANNEL_1, seven_segment_value);        
    // Turn on all the segments and turn off all of the digit points
    //XGpio_DiscreteWrite(&BTN_gpio, CHANNEL_2, 0x0);        

    while(1) {
        // read the value of the switches
        switches = XGpio_DiscreteRead(&SW_gpio, CHANNEL_1);
        // write the value of the switches to the LEDs

        // read the value of the buttons
        buttons = XGpio_DiscreteRead(&BTN_gpio, CHANNEL_1);
        if (buttons & BTND)
            //  If BTND is pressed, invert LEDs
            leds = ~switches;
        else if (buttons & BTNU)
            //  If BTNU is pressed, blank the LEDs
            leds = 0;
        else if (buttons & BTNL)
            //  IF BTNL is pressed, left shift the switches to the LEDs
            leds = switches << 1;
        else if (buttons & BTNR)
            leds = switches >> 1;
        else
            leds = switches;
        // Write the corresponding value to the LEDs
        XGpio_DiscreteWrite(&LED_gpio, CHANNEL_1, leds);        

        // check to see if there is a byte in the receive fifo
        uart_status = Xil_In32(XPAR_UART_AXI_BASEADDR);
        if (~(uart_status & RX_EMPTY_MASK)) {
            //  If there is a byte, read it from the fifo
            unsigned char received_char = Xil_In32(XPAR_UART_AXI_BASEADDR);
            //  Write the received character to the TX fifo
            Xil_Out32(XPAR_UART_AXI_BASEADDR, received_char);
            //  Increment the seven segment display counter
            seven_segment_value = (seven_segment_value + 1);
            XGpio_DiscreteWrite(&SSD_gpio, CHANNEL_1, seven_segment_value);        
        }
        //  If BTNC is pressed, send the character defined by the lower switches out the tx
        if (buttons & BTNC) {
            Xil_Out32(XPAR_UART_AXI_BASEADDR, switches & 0xFF);
        }


    }
    return 0;
}