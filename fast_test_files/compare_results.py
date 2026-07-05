MEM_FILE = "data_for_test1.mem"
TXT_FILE = "uart_capture_test1_clean.txt"


def read_file(filename):
    with open(filename, "r") as f:
        text = f.read()

    # Remove whitespace: spaces, newlines, tabs
    text = text.replace(" ", "")
    text = text.replace("\n", "")
    text = text.replace("\r", "")
    text = text.replace("\t", "")

    return text


expected = read_file(MEM_FILE)
actual = read_file(TXT_FILE)

if len(expected) != len(actual):
    print("FAIL")
    print("Files do not have the same length")
    print("Expected length:", len(expected))
    print("Actual length:  ", len(actual))
    exit()

matches = 0
total = len(expected)

for i in range(total):
    e = expected[i]
    a = actual[i]

    if e == "x" or e == "X":
        matches += 1
    elif e == a:
        matches += 1
    else:
        print("FAIL")
        print("First mismatch at position:", i)
        print("Expected:", e)
        print("Actual:  ", a)
        percent = matches / total * 100
        print("Match:", percent, "%")
        exit()

print("PASS")
print("Match: 100%")

