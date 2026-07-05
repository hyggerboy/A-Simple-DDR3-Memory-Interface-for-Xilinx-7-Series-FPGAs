import serial
import random
import time


PORT = "COM4"
BAUDRATE = 115200

COUNT = 2_097
ADDRESS_START = 0
ADDRESS_STEP = 8   # 128-bit word = 16 bytes

USE_CHOSEN_DATA = False 
CHOSEN_DATA = 0xaa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa

RANDOM_SEED = 4531
PRINT_EVERY = 1000
MAX_FAILED_EXAMPLES = 20


def make_address_packet(address: int, write: bool) -> bytes:
    if address < 0 or address >= (1 << 27):
        raise ValueError("Address must be 27 bits or smaller, max 0x07ffffff")

    return bytes([
        ((1 if write else 0) << 7) | ((address >> 24) & 0x07),
        (address >> 16) & 0xFF,
        (address >> 8) & 0xFF,
        address & 0xFF,
    ])


def make_write_packet(address: int, data: int) -> bytes:
    return make_address_packet(address, True) + data.to_bytes(16, "big")


def make_read_packet(address: int) -> bytes:
    return make_address_packet(address, False)


def get_address(index: int) -> int:
    return ADDRESS_START + index * ADDRESS_STEP


def get_data(rng) -> int:
    if USE_CHOSEN_DATA:
        return CHOSEN_DATA
    return rng.getrandbits(128)


def read_exactly(ser, n: int) -> bytes:
    data = ser.read(n)

    if len(data) != n:
        raise TimeoutError(f"Expected {n} bytes, got {len(data)} bytes")

    return data


def test_addresses():
    last_address = get_address(COUNT - 1)

    if last_address >= (1 << 27):
        raise ValueError(f"Last address too large: 0x{last_address:08X}")

    failed_examples = []
    failures = 0

    total_start = time.perf_counter()

    with serial.Serial(
        PORT,
        BAUDRATE,
        timeout=2,
        write_timeout=2,
        rtscts=False,
        dsrdtr=False,
        xonxoff=False,
    ) as ser:

        try:
            ser.set_buffer_size(rx_size=1024 * 1024, tx_size=1024 * 1024)
        except Exception:
            pass

        ser.reset_input_buffer()
        ser.reset_output_buffer()

        print(f"Writing {COUNT} addresses...")

        write_rng = random.Random(RANDOM_SEED)
        write_start = time.perf_counter()

        for i in range(COUNT):
            address = get_address(i)
            data = get_data(write_rng)

            ser.write(make_write_packet(address, data))

            if (i + 1) % PRINT_EVERY == 0:
                elapsed = time.perf_counter() - write_start
                print(f"Written {i + 1}/{COUNT}, rate={(i + 1) / elapsed:.1f} writes/s")

        ser.flush()

        write_time = time.perf_counter() - write_start

        print(f"Write done: {write_time:.2f} s, rate={COUNT / write_time:.1f} writes/s")

        time.sleep(0.2)
        ser.reset_input_buffer()

        print()
        print(f"Reading {COUNT} addresses...")

        read_rng = random.Random(RANDOM_SEED)
        read_start = time.perf_counter()

        for i in range(COUNT):
            address = get_address(i)
            expected = get_data(read_rng)

            ser.write(make_read_packet(address))

            rx = read_exactly(ser, 16)
            received = int.from_bytes(rx, "big")

            if received != expected:
                failures += 1

                if len(failed_examples) < MAX_FAILED_EXAMPLES:
                    failed_examples.append((i, address, expected, received, rx))

            if (i + 1) % PRINT_EVERY == 0:
                elapsed = time.perf_counter() - read_start
                print(
                    f"Read {i + 1}/{COUNT}, "
                    f"failures={failures}, "
                    f"rate={(i + 1) / elapsed:.1f} reads/s"
                )

        read_time = time.perf_counter() - read_start

    total_time = time.perf_counter() - total_start

    print()
    print("Summary:")
    print(f"ADDRESS START:{ADDRESS_START}")
    print(f"Passed: {COUNT - failures} / {COUNT}")
    print(f"Failed: {failures} / {COUNT}")
    print(f"Failure rate: {100.0 * failures / COUNT:.6f}%")

    print()
    print("Time:")
    print(f"Write time: {write_time:.2f} s")
    print(f"Read time:  {read_time:.2f} s")
    print(f"Total time: {total_time:.2f} s")
    print(f"Write rate: {COUNT / write_time:.1f} writes/s")
    print(f"Read rate:  {COUNT / read_time:.1f} reads/s")

    if failed_examples:
        print()
        print("First failed examples:")
        for i, address, expected, received, rx in failed_examples:
            print(
                f"index={i:08d}, "
                f"addr=0x{address:08X} ({address}), "
                f"expected=0x{expected:032X}, "
                f"received=0x{received:032X}, "
                f"rx={rx.hex(' ')}"
            )


test_addresses()