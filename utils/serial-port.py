import serial
import threading
import time

commands = {
    "CMD_SET_INST": b"\x01",  # 8'd1 in binary
    "CMD_SET_CONTINUOUS": b"\x02",  # 8'd2 in binary
    "CMD_SET_STEP_BY_STEP": b"\x03",  # 8'd3 in binary
    "CMD_RUN_STEP": b"\x04",  # 8'd4 in binary
    "CMD_RESET": b"\x05",  # 8'd5 in binary
}


def send_program(ser, file_path):
    try:
        with open(file_path, "r") as file:
            lines = file.readlines()
            line_count = len(lines)
            # Ensure the line count does not exceed 255
            if line_count > 255:
                print("Error: Program exceeds 255 lines.")
                return
            # Send the line count as a single byte
            ser.write(line_count.to_bytes(1, byteorder='big'))
            print(f"Sent line count: {line_count}")
            # Send each line as a 32-bit value
            for line in lines:
                data = int(line.strip(), 2).to_bytes(4, byteorder='big')
                ser.write(data)
                print(f"Sent: {data}")
    except FileNotFoundError:
        print("File not found. Please enter a valid file path.")
    except Exception as e:
        print(f"An error occurred: {e}")


def read_from_port_debug(ser):
    while True:
        reading = ser.read(100)  # TODO: Adjust the buffer size as needed
        if reading:
            print("\nReceived: ")
            binary_str = ''  # Initialize an empty string to accumulate binary representations
            for byte in reading:
                # Print each byte in hexadecimal format
                print(f"{byte:02x} ", end='')
                # Accumulate the binary string representation
                binary_str += format(byte, '08b') + ' '
            print()  # Add a newline
            print(f"Binary string format: {binary_str}")

def write_mock_data_to_port(ser):
    # Mock Program Counter (PC) data
    pc = 0xaabbccdd  # Example PC value
    ser.write(pc.to_bytes(4, byteorder='big'))

    # Mock Registers data
    for i in range(32):
        reg_value = i*3  # Example register value
        ser.write(reg_value.to_bytes(4, byteorder='big'))

    # Mock Memory data
    for i in range(256):
        mem_value = i*2  # Example memory value
        ser.write(mem_value.to_bytes(4, byteorder='big'))

    print("Mock PC, registers, and memory data written to port.")

def read_from_port(ser):
    # Read Program Counter (PC)
    pc_data = ser.read(4)  # Read 4 bytes (32 bits)
    pc = int.from_bytes(pc_data, byteorder='big')
    print(f"Program Counter (Hex): {pc:08X}")

    # Read Registers
    print("Registers:")
    for i in range(32):  # 32 registers
        reg_data = ser.read(4)  # Read 4 bytes (32 bits) for each register
        reg_value = int.from_bytes(reg_data, byteorder='big')
        print(f"R{i}: {reg_value}")

    # Read Memory
    print("Memory:")
    for i in range(256):  # 256 memory slots
        mem_data = ser.read(4)  # Read 4 bytes (32 bits) for each memory slot
        mem_value = int.from_bytes(mem_data, byteorder='big')
        print(f"Mem[{i}]: {mem_value}") 


def write_to_port(ser):
    while True:
        command = input("Enter command (type 'exit' to quit): ")
        if command.lower() == "exit":
            break
        elif command.upper() in commands:
            # If the command is CMD_SET_INST, prompt for a file path
            if command.upper() == "CMD_SET_INST":
                file_path = input("Enter the path to the binary program file: ")
                # First, send the CMD_SET_INST command
                ser.write(commands[command.upper()])
                # Then, call send_program to send the file content
                send_program(ser, file_path)
            else:
                ser.write(commands[command.upper()])
                print(f"Sent command {command.upper()}")
        else:
            print("Invalid command. Available commands are:", ', '.join(commands.keys()))


def main():
    try:
        # with serial.Serial('/dev/ttyUSB0', 9600, timeout=1) as ser:
        with serial.serial_for_url(
            "loop://",
            timeout=1,
            baudrate=9600,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
        ) as ser:
            if ser.isOpen():
                print("Using port:", ser.name)
                ser.flushInput()
                ser.flushOutput()

                # Starting thread for reading from port
                thread = threading.Thread(target=read_from_port, args=(ser,))
                thread.daemon = True
                thread.start()

                # Function to write data to port
                #write_to_port(ser)
                # Testing
                write_mock_data_to_port(ser)

                # Wait before closing to ensure all data is transmitted/received
                time.sleep(1)

            else:
                print("Failed to open serial port")

    except serial.SerialException as e:
        print(f"Serial exception occurred: {e}")


if __name__ == "__main__":
    main()
