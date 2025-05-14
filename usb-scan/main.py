import subprocess
import re
from typing import List, Tuple
from dataclasses import dataclass

HEADER_REGEX = re.compile(
    r"^(Bus *)(device *)(vid:pid *)(probe type *)(manufacturer *)(serial *)(product *)$"
)


@dataclass()
class DeviceInfo:
    index: int
    bus: int
    device: int
    vid: str
    pid: str
    type: str
    manufacturer: str
    serial_code: str
    description: str


def get_header_slices(header: str) -> List[slice]:
    N = 7

    m = HEADER_REGEX.match(header)
    assert m
    assert m.lastindex == N

    slices = []
    for i in range(N):
        start = m.start(i + 1)
        end = None if i == N - 1 else m.end(i + 1)
        slices.append(slice(start, end))

    return slices


def get_lines(text: str) -> Tuple[str, List[str]]:
    # Given the output text of the open fpga programmer --list command,
    # return the header line and a list of the device lines.

    lines = text.splitlines()

    lines = [line for line in lines if line.strip() and line.strip() != "empty"]

    headers_lines = [line for line in lines if line.startswith("Bus")]
    devices_lines = [line for line in lines if not line.startswith("Bus")]

    assert len(headers_lines) == 1
    return (headers_lines[0], devices_lines)


def extract_field(l: str, s):
    value = l[s].strip()
    if value == "none":
        value = ""
    return value


def get_devices(text: str) -> DeviceInfo:
    header, devices_lines = get_lines(result.stdout)
    slices = get_header_slices(header)

    devices = []
    for index, line in enumerate(devices_lines):
        assert len(slices) == 7

        # -- Extract fields
        bus = extract_field(line, slices[0])
        device = extract_field(line, slices[1])
        vid_pid = extract_field(line, slices[2])
        type = extract_field(line, slices[3])
        manufacturer = extract_field(line, slices[4])
        serial_code = extract_field(line, slices[5])
        description = extract_field(line, slices[6])

        # Split pid_vid to pid and vid
        tokens = vid_pid.split(":")
        assert len(tokens) == 2, tokens
        assert tokens[0].startswith("0x")
        assert tokens[1].startswith("0x")
        vid = tokens[0][2:]
        pid = tokens[1][2:]

        device = DeviceInfo(
            index=index,
            bus=int(bus),
            device=int(device),
            vid=vid,
            pid=pid,
            type=type,
            manufacturer=manufacturer,
            serial_code=serial_code,
            description=description,
        )
        devices.append(device)

    return devices


result = subprocess.run(
    ["apio", "raw", "--", "openFPGALoader", "--scan-usb"],
    capture_output=True,
    text=True,
)

assert result.returncode == 0

devices = get_devices(result.stdout)

for device in devices:
    print(f"DEVICE: {device}")

#
# header, devices_lines = get_lines(result.stdout)

# print(f"{result.returncode=}")
# print(f"{result.stdout}")

# lines = result.stdout.splitlines()


# lines = [line for line in lines if line.strip() and line.strip() != "empty"]

# header_lines = [line for line in lines if line.startswith("Bus")]
# device_lines = [line for line in lines if not line.startswith("Bus")]

# print(f"HEADER: [{header}]")

# print()

# for line in devices_lines:
#     print(f"DEVICE: [{line}]")

# assert len(header_lines) == 1
# header = header_lines[0]

# slices = get_header_slices(header)

# print(f"{slices=}")

# m = HEADER_REGEX.match(header)

# for i, slice in enumerate(slices):
#     text = header[slice]
#     print()
#     print(f"TEST  [{text}]")
#     print(f"MATCH [{m.group(i+1)}]")


# devices_rows = []
# for line in devices_lines:
#     fields = []
#     for slice in slices:
#         fields.append(line[slice].strip())
#     devices_rows.append(fields)

# for row in devices_rows:
#     print(f"ROW {row}")


# devices = []
# for line in devices_lines:
#     assert len(slices) == 7

#     # -- Extract fields
#     bus = extract_field(line, slices[0])
#     device = extract_field(line, slices[1])
#     vid_pid = extract_field(line, slices[2])
#     type = extract_field(line, slices[3])
#     manufacturer = extract_field(line, slices[4])
#     serial_code = extract_field(line, slices[5])
#     description = extract_field(line, slices[6])


#     # Split pid_vid to pid and vid
#     tokens = vid_pid.split(":")
#     assert len(tokens) == 2, tokens
#     assert tokens[0].startswith("0x")
#     assert tokens[1].startswith("0x")
#     vid = tokens[0][2:]
#     pid = tokens[1][2:]

#     device = DeviceInfo(bus=int(bus), device=int(device), vid=vid, pid=pid, type=type,
#                     manufacturer=manufacturer, serial_code=serial_code, description=description)
#     devices.append(device)
