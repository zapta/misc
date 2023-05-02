from __future__ import annotations

import argparse
import asyncio
import logging
from client import BaseClientCallbacks, SerialMessagingClient, Status
from typing import  Tuple, Optional


logger = logging.getLogger("main")
logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser()
parser.add_argument("--port", dest="port", default=None, help="Serial port to use.")
parser.add_argument('--send',
                    dest="send",
                    default=True,
                    action=argparse.BooleanOptionalAction,
                    help="Specifies if to auto send periodically.")
args = parser.parse_args()


class MyClientCallbacks(BaseClientCallbacks):
  #@override(BaseClientCallbacks)
  def on_command(
        self,
        # client: SerialMessagingClient,
        endpoint: int,
        data: bytearray,
    ) -> Tuple[Status, Optional[bytearray]]:
        print("on_command_with_resp()")
        return (123, bytearray([1, 2, 3, 4]))
    


async def async_main():
    print("Async main started", flush=True)
    print(f"Connecting to port: {args.port}", flush=True)
    client = SerialMessagingClient(args.port, MyClientCallbacks())
    status = await client.connect()
    print("Connected: status = {status}", flush=True)

    while True:
        # await asyncio.sleep(3)
        await asyncio.sleep(0.5)
        if args.send:
            status, data = await client.send_command(200, bytearray([0x13, 0x00, 0x7D, 0x00, 0x7E, 0x00]))
            print(f"Result: {status}, {data}")


print("Main started")
asyncio.run(async_main())
