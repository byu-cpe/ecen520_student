# SPI Protocol

For one of your assignments you will be implementing an SPI controller to communicate with an SPI device.
In this lecture we will review the SPI protocol and discuss how you can implement this protocol in RTL.

**Reading**

* [Analog Devices SPI Protocol Overview](https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html)
    * Understand what each of the signals do
    * Understand the timing of SPI Mode 0 in detail
    * Understand multi-sub-node configuration in Figure 6
* [Accelerometer Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL362.pdf) pages 21-37
    * Understand how register reads and writes are performed using SPI on this device (page 21-22)
    * Briefly scan through the pages of device registers (no need to read them in detail - just become familiar with what registers are available``)

**Reference**

**Key Concepts**

* Basic SPI protocol operation
* How multiple devices can operate on the same SPI bus
* How to read and write registers on the ADXL362 accelerometer using SPI
