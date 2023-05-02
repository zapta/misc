from __future__ import annotations

import argparse
import asyncio
import logging
import time
from client import BaseClientCallbacks, SerialMessagingClient
from typing import  Tuple, Optional
from packets import PacketStatus


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



def handle_command_endpoint_20(data: bytearray) -> Tuple[int, bytearray]:
    return (PacketStatus.OK.value, bytearray([1, 2, 3, 4]))

  
class MyClientCallbacks(BaseClientCallbacks):
  def on_command(
        self,
        endpoint: int,
        data: bytearray,
    ) -> Tuple[int, Optional[bytearray]]:
        print(f"Main received command: {endpoint}, {data.hex(sep=' ')}")
        if (endpoint == 20):
          return handle_command_endpoint_20(data)
        return (PacketStatus.UNHANDLED.value, bytearray())

    


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
            endpoint = 200
            tx_data = bytearray([0x13, 0x00, 0x7D, 0x00, 0x7E, 0x00])
            print(f"------------")
            print(f"Command: {endpoint}, {tx_data.hex(sep=' ')}")
            start_time = time.time()
            rx_status, rx_data = await client.send_command_blocking(endpoint, tx_data, timeout=0.2)
            print(f"{time.time() - start_time:.6f}", flush=True)
            print(f"Command result: {rx_status}, {rx_data.hex(sep=' ')}", flush=True)


print("Main started")
asyncio.run(async_main())
