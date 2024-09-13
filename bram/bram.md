<!--

Need to be more clear on Putty settings. 
- Parity? (enforce it!)
- Default baud rate?
They use glbl.v file for simulation. Need to include in their repository.
Don't hard code any paths in makefile! (perhaps have an environment variable that is set, so I can reuse their makefiles)
- Have them simulate the full fight song

Future: if they hit enter, make sure both CR/LF are sent back
- buffer empties when right pressed.
- start fight song with new line (make it more clear how to set up putty and what to send at the end of the line)
- Have the fight song spit out the text as fast as possible (no delays).
-->

# BRAM

In this assignment you will practice instancing BRAMs and interface them to your UART.
You will use your BRAM to buffer data received from the UART receiver and to send over the transmitter.
Two different BRAMs will be used in this assignment.

<!--
You can create this design in a single HDL file if you like.
-->

## Top-Level Design

Start this assignment by creating a top-level module with the same top-level ports as the UART receiver assignment.
Add the BTNL and BTNR ports to the top-level module to represent the left and right buttons on the Basys3 board (you will need a debouncer for each of these buttons).
You may want to copy your top-level design and modify it as a starting point.
Include the following in your top-level design:

* Attach the `CPU_RESETN` signal to two flip-flops as you did in the previous assignment.
* Instance your transmitter much as you did in the previous assignment
    * Hook the TX output signal to the top-level `UART_RXD_OUT` pin of the board (i.e., to the host)
    * Attach the TX busy signal to the LED16_B signal to provide a blue LED indicator when the transmitter is busy
* Instance your receiver
    * Add a two flip-flop synchronizer between the RX input signal (`UART_TXD_IN`)
    * Attach the rx busy signal to the LED17_R signal to provide a red LED indicator when the receiver is busy
    * Attach the rx error signal to the LED17_G signal to provide a green LED indicator when the receiver has an error
* Attach the lower 8 switches on the board to the lower 8 LEDs.
* Create four 8-bit registers that hold the last four values received by your receiver
* Instance your seven segment display controller and display the last four values as you did in the previous assignment
* Hook up the center button (BTNC) to your circuit through a debouncer and cause the transmitter to send the values on the switches when this button has been pushed.

The difference between this assignment and the previous one is that you will transmit data over the UART from three different sources: BRAM Fight song, BRAM buffer, and the switches with BTNC.
In addition, you will be saving the storing the received values into a BRAM buffer.
More details on these additions will be described below.

## Fight Song BRAM

Instance a single BRAM as a device primitive in your HDL (do not 'infer' the BRAM with your RTL).
This BRAM should be organized as 8bit x 4096 (i.e., 4096 8-bit ASCII characters).
Initialize the contents of the BRAM to include the text of the BYU fight song (see below).
Note that the fight song will not fill the entire BRAM so you should only send the characters associated with the fight song and no more.
Make sure you send new line characters(\r\n) at the end of each line.

You should design your circuit so that when the **left** button is pressed, the _entire_ fight song is sent over the UART transmitter.
You will need to implement flow control so that you don't send another character until the previous character has been sent.
Also, you will need to put some sort of null or stop character at the end of the fight song so that you know when to stop.

```
Rise all loyal Cougars and hurl your challenge to the foe.
You will fight, day or night, rain or snow.
Loyal, strong, and true
Wear the white and blue.
While we sing, get set to spring.
Come on Cougars it's up to you. Oh!

Chorus:
Rise and shout, the Cougars are out
along the trail to fame and glory.
Rise and shout, our cheers will ring out
As you unfold your victr'y story.

On you go to vanquish the foe for Alma Mater's sons and daughters.
As we join in song, in praise of you, our faith is strong.
We'll raise our colors high in the blue
And cheer our Cougars of BYU.
```

If the left button is pressed again during transmission you should ignore it (i.e., send the entire text before sending another one)

## BRAM Playback

Implement a UART "buffer" with a second BRAM that saves the data received from the UART receiver one character after another.
Infer a second BRAM from HDL (no instancing of primitive) that is organized as 8x4096.
This BRAM should store each character received from the UART in one address after the next.
Create a counter that indicates the location where to store the next UART received character (you will need to display this counter in hex on the seven segment display).
When the **right** button is pressed, your circuit should send each character received in the BRAM over the UART back to the host.
Once the data has been sent, reset your counters so that you only send the new data received after the button has been pressed (you don't want to send the data received more than once).

Your BRAM will act like a FIFO: characters received from the UART are placed in the BRAM FIFO and when the button is pressed, the BRAM fifo is read and sent over the transmitter until the FIFO has emptied.

## Testbench

Create a top-level testbench that instantiates your design and simulates the behavior of all three ways to send data over the UART.

* Hook up my UART receiver model that prints out the characters it receives.
* Instance a second copy of your transmitter in the testbench so that you can provide data for the receiver. Control this by your testbench.
* Hook up the seven segment display checker (even though we don't really care about it much)

* Initialize and reset your design
* Have your testbench transmitter send the characters "Hello World" to your receiver
* Send two characters over the transmitter by pressing BTNC
* Press buttonL to send the fight song. Send the entire sequence to make sure it stops (this may take a while)
* Have your testbench transmitter send the characters "Good Bye" to your receiver
* Press button R to send the data in your BRAM buffer out the transmitter

Create a makefile rule `sim_top` that performs this simulation from the command line. Generics?
Create a makefile rule `gen_bit` that generates a bitstream for your top-level design. Generics?

## Submission

Add detailed timing analysis to your README.md file.
