import subprocess
import re
from typing import List, Tuple
from dataclasses import dataclass

TEXT="""
empty
Bus device vid:pid       probe type      manufacturer serial               product
000 001    0x0403:0x6010 FTDI2232        AlhambraBits none                 Alhambra II v1.0A - B09-335
001 001    0x0403:0x6010 FTDI2232        tinyVision.ai FT94RQ8V             UPduino v3.1c
001 001    0x0403:0x6010 FTDI2232        tinyVision.ai.v3 FT94RQ8V             UPduino v3.1c
"""

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

    def dump(self):
        print(f"Device [{self.index}]")
        print(f"    bus:     [{self.bus}]")
        print(f"    device:  [{self.device}]")
        print(f"    vid:     [{self.vid}]")
        print(f"    pid:     [{self.pid}]")
        print(f"    type:    [{self.type}]")
        print(f"    manufct: [{self.manufacturer}]")
        print(f"    serial:  [{self.serial_code}]")
        print(f"    Desc:    [{self.description}]")


def get_header_fields_starts(header: str) -> List[int]:
    """Given an header line, returns the start indices of the columns
    names. """

    # The expected number of fields.
    N = 7
    assert HEADER_REGEX.groups == N

    m = HEADER_REGEX.match(header)
    assert m
    assert m.lastindex == N

    fields_starts = []
    for i in range(N):
        fields_starts.append(m.start(i + 1))


    return fields_starts


def get_lines(text: str) -> Tuple[str, List[str]]:
    # Given the output text of the open fpga programmer --list command,
    # return the header line and a list of the device lines.

    lines = text.splitlines()

    lines = [line for line in lines if line.strip() and line.strip() != "empty"]

    headers_lines = [line for line in lines if line.startswith("Bus")]
    devices_lines = [line for line in lines if not line.startswith("Bus")]

    assert len(headers_lines) == 1
    return (headers_lines[0], devices_lines)


def extract_field(line:str, field_index: int, fields_starts:List[int]):
    start = fields_starts[field_index]
    end = fields_starts[field_index + 1] if field_index < (len(fields_starts) - 1) else None
    value = line[slice(start, end)].strip()
    if value == "none":
        value = ""
    return value


def get_devices(text: str) -> DeviceInfo:
    header, devices_lines = get_lines(text)
    header_starts = get_header_fields_starts(header)

    devices = []
    for index, line in enumerate(devices_lines):
        assert len(header_starts) == 7

        line_starts = header_starts.copy()

        # -- Extract fields
        bus = extract_field(line, 0, line_starts)
        device = extract_field(line,  1, line_starts)
        vid_pid = extract_field(line, 2, line_starts)
        type = extract_field(line, 3, line_starts)
        manufacturer = extract_field(line, 4, line_starts)
        serial_code = extract_field(line, 5, line_starts)
        description = extract_field(line, 6, line_starts)

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


# result = subprocess.run(
#     ["apio", "raw", "--", "openFPGALoader", "--scan-usb"],
#     capture_output=True,
#     text=True,
# )
# assert result.returncode == 0
# text = result.stdout

text = TEXT

devices = get_devices(text)

for device in devices:
    print()
    device.dump()
print()


