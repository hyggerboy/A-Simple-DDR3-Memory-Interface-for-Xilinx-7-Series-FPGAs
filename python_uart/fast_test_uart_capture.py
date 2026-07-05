import serial
import time

PORT = "COM4"
BAUD = 115200
WORD_COUNT = 256
BYTES_PER_WORD = 16  # 128 bits


def read_exact(ser, n):
    data = bytearray()

    while len(data) < n:
        chunk = ser.read(n - len(data))

        if chunk:
            data.extend(chunk)
        else:
            print(f"Timeout: got {len(data)} of {n} bytes")
            break

    return bytes(data)


words = []

with serial.Serial(PORT, BAUD, timeout=20) as ser:
    ser.reset_input_buffer()

    print(f"Listening on {PORT} @ {BAUD} baud...")
    print("Start the FPGA transfer now.\n")

    time.sleep(0.2)

    for i in range(WORD_COUNT):
        raw = read_exact(ser, BYTES_PER_WORD)

        if len(raw) != BYTES_PER_WORD:
            print(f"Word {i}: incomplete read, stopping.")
            break

        value = int.from_bytes(raw, byteorder="big")
        words.append(value)

        print(f"{i:03d}: 0x{value:032X}")


# File 1: readable format
with open("uart_capture_test1.txt", "w") as f:
    for i, value in enumerate(words):
        f.write(f"{i:03d}: 0x{value:032X}\n")


# File 2: raw hex only
# This is easier to compare against expected_read_test1.mem
with open("uart_capture_test1_raw.txt", "w") as f:
    for value in words:
        f.write(f"{value:032X}\n")


print(f"\nDone. Captured {len(words)} of {WORD_COUNT} words.")
print("Saved to uart_capture_test2.txt")
print("Saved to uart_capture_test2_raw.txt")