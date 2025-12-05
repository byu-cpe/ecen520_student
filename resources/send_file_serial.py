#!/usr/bin/python3

# Manages file paths
import serial
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", type=str, help="Text file to send")
    parser.add_argument("--port", type=str, required = True, help="Serial port to use (i.e., /dev/ttyAMA0)")
    parser.add_argument("--baud", type=int, default = 115200, help="Baud rate to use (i.e., 115200)")
    parser.add_argument("--parity", type=str, default = "none", help="Parity (none, even, odd). None default")
    #argparse.add_argument("--parity", type=str, help="Parity to use (i.e., N)")
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
    try:
        ser = serial.Serial(port=args.port, baudrate=args.baud, timeout=4, parity=parity, 
                            stopbits = 1, bytesize=serial.EIGHTBITS)
    except Exception as e:
        print("Error: Could not open serial port")
        print(e)
        return

    print("Sending file:", args.filename)
    f = open(args.filename,"rb")
    bytes_read = 0
    BYTES_PER_DOT = 1000
    while True:
        byte = f.read(1)
        if not byte:
            break
        ser.write(byte)
        bytes_read += 1
        if bytes_read % BYTES_PER_DOT == 0:
            print(".", end="", flush=True)
            ser.flush()
    print("\nFile sent, total bytes:", bytes_read)

    # Now wait for the data to be received
    ser.flush()
    return
    f.seek(0)
    bytes_read = 0
    while True:
        byte = ser.read(1)
        if not byte:
            break
        file_byte = f.read(1)
        if byte != file_byte:
            print("\nError: Data mismatch")
            return
        bytes_read += 1
        if bytes_read % BYTES_PER_DOT == 0:
            print(".", end="")
    print("\nData transfer complete and verified")
    ser.close()
    f.close()

if __name__ == "__main__":
    main()