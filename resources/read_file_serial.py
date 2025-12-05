#!/usr/bin/python3

# Manages file paths
import serial
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", type=str, help="Text file for received data")
    parser.add_argument("--port", type=str, required = True, help="Serial port to use (i.e., /dev/ttyAMA0)")
    parser.add_argument("--baud", type=int, default = 115200, help="Baud rate to use (i.e., 115200)")
    parser.add_argument("--parity", type=str, default = "none", help="Parity (none, even, odd). None default")
    args = parser.parse_args()

    if args.parity.lower() == "none":
        parity = serial.PARITY_NONE
    elif args.parity.lower() == "even":
        parity = serial.PARITY_EVEN
    elif args.parity.lower() == "odd":
        parity = serial.PARITY_ODD
    else:
        print("Error: Invalid parity option")
        return
    read_timeout = 3.0
    try:
        ser = serial.Serial(port=args.port, baudrate=args.baud, timeout=read_timeout, 
                            parity=parity, 
                            stopbits = 1, bytesize=serial.EIGHTBITS)
    except Exception as e:
        print("Error: Could not open serial port")
        print(e)
        return

    f = open(args.filename,"wb")
    input("Press Enter to start reading the serial port...")
    bytes_read = 0
    BYTES_PER_DOT = 1000
    while True:
        byte = ser.read(1)
        if not byte:
            break
        f.write(byte)
        bytes_read += 1
        if bytes_read % BYTES_PER_DOT == 0:
            print(".", end="", flush=True)
    print()
    f.close()
    print("File received, total bytes:", bytes_read)
    ser.close()


if __name__ == "__main__":
    main()