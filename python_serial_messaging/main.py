from __future__ import annotations

import argparse
import asyncio
import logging

from client import SerialMessagingClient
from typing import Tuple, Optional
from packets import PacketStatus

# Set default logging level for the entire program.
logging.basicConfig(level=logging.DEBUG)

logger = logging.getLogger("main")

parser = argparse.ArgumentParser()
parser.add_argument("--port", dest="port", default=None, help="Serial port to use.")
parser.add_argument('--send',
                    dest="send",
                    default=True,
                    action=argparse.BooleanOptionalAction,
                    help="Specifies if to auto send periodically.")
args = parser.parse_args()


async def command_async_callback(endpoint: int, data: bytearray) -> Tuple[int, bytearray]:
    logger.info(f"Received command: [%d] %s", endpoint, data.hex(sep=' '))
    if (endpoint == 20):
        return handle_command_endpoint_20(data)
    return (PacketStatus.UNHANDLED.value, bytearray())


def handle_command_endpoint_20(data: bytearray) -> Tuple[int, bytearray]:
    status, response_data = (PacketStatus.OK.value, bytearray([1, 2, 3, 4]))
    logger.info(f"Command response: [%d] %s", status, response_data.hex(sep=' '))
    return (status, response_data)


async def async_main():
    logger.info("Started.")
    assert(args.port is not None)
    client = SerialMessagingClient(args.port, command_async_callback)
    await client.connect()
    logger.info("Connected")
    while True:
        # await asyncio.sleep(3)
        await asyncio.sleep(0.5)
        if args.send:
            endpoint = 20
            tx_data = bytearray([0x13, 0x00, 0x7D, 0x00, 0x7E, 0x00])
            print(f"------------", flush=True)
            logger.info("Sending command: [%d], %s", endpoint, tx_data.hex(sep=' '))
            rx_status, rx_data = await client.send_command_blocking(endpoint, tx_data, timeout=0.2)
            logger.info(f"Command result: [%d], %s", rx_status, rx_data.hex(sep=' '))

asyncio.run(async_main())
