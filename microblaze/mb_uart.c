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

#define BTNC_LOW_STABLE 0
#define BTNC_HIGH_BOUNCING 1
#define BTNC_HIGH_STABLE 2
#define BTNC_LOW_BOUNCING 3
#define BOUNCE_DELAY 10000

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
    unsigned int buttons;        // If the left and right buttons are pressed simultaneously, 

    unsigned int tx_sent = 0;
    unsigned int rx_received = 0;
    unsigned int uart_status;
    unsigned int ssd_value = 0;
    // Button C debouncer states
    int bounce_count = 0;
    int btnc_state = BTNC_LOW_STABLE;
    int btnc_pressed = 0;

    // Initialize the seven segment display with zero
    XGpio_DiscreteWrite(&SSD_gpio, CHANNEL_1, 0);        
    // Turn on all the segments and turn off all of the digit points
    //XGpio_DiscreteWrite(&BTN_gpio, CHANNEL_2, 0x0); 
    // Clear the FIFOs       
    Xil_Out32(XPAR_UART_AXI_BASEADDR+4, switches & 0x3);
    while(1) {
        // Read UART status
        uart_status = Xil_In32(XPAR_UART_AXI_BASEADDR+4);
        // read the value of the switches
        switches = XGpio_DiscreteRead(&SW_gpio, CHANNEL_1);
        // read the value of the buttons
        buttons = XGpio_DiscreteRead(&BTN_gpio, CHANNEL_1);
        //
        if (buttons & BTND)
            //  If BTND is pressed, invert LEDs
            leds = ~switches;
        else if (buttons & BTNU)
            //  If BTNU is pressed, blank the LEDs
            leds = uart_status;
        else if (buttons & BTNL)
            //  IF BTNL is pressed, left shift the switches to the LEDs
            leds = switches << 1;
        else if (buttons & BTNR)
            leds = switches >> 1;
        else
            leds = switches;
        // Write the corresponding value to the LEDs
        XGpio_DiscreteWrite(&LED_gpio, CHANNEL_1, leds);        
        // Read a value from the uart if the RX fifo is not empty
        if ((uart_status & RX_EMPTY_MASK) == 0) {
            //  If there is a byte, read it from the fifo
            unsigned char received_char = Xil_In32(XPAR_UART_AXI_BASEADDR);
            //  Write the received character to the TX fifo
            Xil_Out32(XPAR_UART_AXI_BASEADDR, received_char);
            //  Increment the counters
            rx_received += 1;
            tx_sent += 1;
        }

        //  BTNC debounce state machine in software
        btnc_pressed = (buttons & BTNC)  > 0;
        switch(btnc_state) {
            case BTNC_LOW_STABLE:
                bounce_count = 0;
                if (btnc_pressed)
                    btnc_state = BTNC_HIGH_BOUNCING;
                break;
            case BTNC_HIGH_BOUNCING:
                if (btnc_pressed==0)
                    btnc_state = BTNC_LOW_STABLE;
                else {
                    bounce_count += 1;
                    if (bounce_count > BOUNCE_DELAY) {
                        btnc_state = BTNC_HIGH_STABLE;
                        // Do actions associated with button here
                        tx_sent += 1;
                        Xil_Out32(XPAR_UART_AXI_BASEADDR, switches & 0xFF);
                    }
                }
                break;
            case BTNC_HIGH_STABLE:
                bounce_count = 0;
                if (btnc_pressed==0)
                    btnc_state = BTNC_LOW_BOUNCING;
                break;
            case BTNC_LOW_BOUNCING:
                if (btnc_pressed)
                    btnc_state = BTNC_HIGH_STABLE;
                else {
                    bounce_count += 1;
                    if (bounce_count > BOUNCE_DELAY)
                        btnc_state = BTNC_LOW_STABLE;
                }
                break;
        }


        ssd_value = ((rx_received & 0xff) << 24) | ((tx_sent & 0xff) << 16) | ((uart_status & 0xff) << 8) | (switches & 0xff);
        XGpio_DiscreteWrite(&SSD_gpio, CHANNEL_1, ssd_value);        

    }
    return 0;
}