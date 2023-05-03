from __future__ import annotations

import argparse
import asyncio
import serial_asyncio
import logging
import sys

logger = logging.getLogger(__name__)
# logging.root.setLevel(logging.DEBUG)
logger.error("Logger test (ERROR)")
sys.exit(0)



parser = argparse.ArgumentParser()
parser.add_argument("--port", dest="port", default=None, help="Serial port to use.")
parser.add_argument('--master',
                    dest="master",
                    default=False,
                    action=argparse.BooleanOptionalAction,
                    help="Specifies if initiated transmission.")
args = parser.parse_args()


class SerialProtocol(asyncio.Protocol):
    def __init__(self):
        self.__transport = None

    def connection_made(self, transport):
        print(f"port opened", flush=True)
        self.__transport = transport
        transport.serial.rts = False

    def data_received(self, data: bytes):
        if args.master:
            print(f"Master rx", flush=True)
        else:
            # print(f"Slave rx/tx", flush=True)
            self.__transport.write(data)

    def connection_lost(self, exc):
        print('port closed', flush=True)

    def pause_writing(self):
        print('Writing paused', flush=True)

    def resume_writing(self):
        print('Writing resumed', flush=True)


async def async_main():
    transport, protocol = await serial_asyncio.create_serial_connection(
        asyncio.get_event_loop(), SerialProtocol, args.port, 115200)
    while True:
        await asyncio.sleep(0.5)
        logger.error("Logger test (ERROR)")
        if args.master:
            print(f"Master tx", flush=True)
            transport.write(bytearray([0x55]))


print("Main started")
asyncio.run(async_main())
