import asyncio
import serial_asyncio

class OutputProtocol(asyncio.Protocol):
    def connection_made(self, transport):
        self.transport = transport
        print('port opened', transport, flush=True)
        transport.serial.rts = False  # You can manipulate Serial object via transport
        transport.write(b'Hello, World!\n')  # Write serial data via transport

    def data_received(self, data):
        print('data received', repr(data), flush=True)
        #if b'\n' in data:
        #    self.transport.close()

    def connection_lost(self, exc):
        print('port closed', flush=True)
        self.transport.loop.stop()

    def pause_writing(self):
        print('pause writing', flush=True)
        print(self.transport.get_write_buffer_size(), flush=True)

    def resume_writing(self):
        print(self.transport.get_write_buffer_size(), flush=True)
        print('resume writing', flush=True)

loop = asyncio.get_event_loop()
coro = serial_asyncio.create_serial_connection(loop, OutputProtocol, 'COM20', baudrate=115200)
transport, protocol = loop.run_until_complete(coro)
print("opened", flush=True)
loop.run_forever()
loop.close()

