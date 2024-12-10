# Wishbone Bus

The wishbone bus is a common bus used for open source hardware for system-on-chip (SOC) systems.
The bus protocol is relatively straight forward and many legacy busses use a very similar approach.
Understanding the wishbone bus protocol provides a good understanding of many bus integration approaches.

**Reading**

  * [Wishbone Spec](https://cdn.opencores.org/downloads/wbspec_b4.pdf)

**Reference**

**Key Concepts**

  * What is an address space and how IP is allocated to address spaces
  * Difference between a wishbone master and wishbone slave
  * Different bus architectures with wishbone: point to point, data flow, shared bus, cross bar
  * Understand the purpose of the following signals: ACK, CYC, STALL, LOCK, TRY, STB, and WE
  * Understand how reads and writes occur using the standard protocol
  * Understand the difference between the pipelined and standard protocols
  * Be able to interpret wishbone bus transaction waveforms
