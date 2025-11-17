// main.c for the demo_io MicroBlaze project

// This include file lists the base addresses of all the devices in the processor.
// It is located: platform/sources/standalone_microblaze_0/bsp/include
#include "xparameters.h"

// This include file defines the functions available for the GPIO module.
// It is located: platform/sources/standalone_microblaze_0/bsp/libsrc/gpio/src
#include "xgpio.h"

int main() {

    // A data structure stores the base information for each device. One is needed
    // for both GPIO modules
    XGpio LED_gpio = {0}; // intialize struct to 0
    XGpio SW_gpio = {0};
    // Intialize the data structures for the devices. Use the base address as found
    // in the xparameters.h
    XGpio_Initialize(&LED_gpio, XPAR_AXI_GPIO_LED_BASEADDR);
    XGpio_Initialize(&SW_gpio, XPAR_AXI_GPIO_SW_BASEADDR);
    unsigned int switches;
    int channel = 1; // Only have one channel for each GPIO

    while(1) {
        // read the value of the switches
        switches = XGpio_DiscreteRead(&SW_gpio, channel);
        // write the value of the switches to the LEDs
        XGpio_DiscreteWrite(&LED_gpio, channel, switches);        
    }
    return 0;
}