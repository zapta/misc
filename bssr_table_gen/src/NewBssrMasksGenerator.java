
public class NewBssrMasksGenerator {

    // Include here all port that output Data bits.
    enum Port {
        A,
        B
    }

    // A port pin identifier.
    static class Pin {
        final Port port;
        final int pin_index;  // MSB=15, LSB=0;

        public Pin(Port port, int pin_index) {
            this.port = port;
            this.pin_index = pin_index;
        }

        public String toString() {
            return "P" + port.name() + pin_index;
        }
    }

//    // In addition to the 16 bit parallel data, we also
//    // want to reset the WR pin.
//    static final Pin WR_PIN = new Pin(Port.A, 0);
//
//    // Maps the 16 data bit index to pin.
//    static final Pin[] DATA_PINS = new Pin[]{
//            new Pin(Port.B, 12),  // D0
//            new Pin(Port.B, 13),  // D1
//            new Pin(Port.B, 14),  // D2
//            new Pin(Port.B, 15),  // D3
//
//            new Pin(Port.A, 10),  // D4
//            new Pin(Port.A, 9),   // D5
//            new Pin(Port.A, 10),  // D6
//            new Pin(Port.A, 7),   // D7
//
//            new Pin(Port.A, 6),   // D8
//            new Pin(Port.A, 5),   // D9
//            new Pin(Port.A, 15),  // D10
//            new Pin(Port.A, 4),   // D11
//
//            new Pin(Port.A, 3),   // D12
//            new Pin(Port.B, 4),   // D13
//            new Pin(Port.A, 2),   // D14
//            new Pin(Port.B, 5),   // D15
//    };


    // Id addition to the 16 bit parallel data, we also
    // want to reset the WR pin.
    static final Pin WR_PIN = new Pin(Port.A, 9);

    // Maps the 16 data bit index to pin.
    static final Pin[] DATA_PINS = new Pin[]{
            new Pin(Port.A, 0),   // D0
            new Pin(Port.A, 1),   // D1
            new Pin(Port.A, 2),   // D2
            new Pin(Port.A, 3),   // D3

            new Pin(Port.A, 4),   // D4
            new Pin(Port.A, 5),   // D5
            new Pin(Port.A, 6),   // D6
            new Pin(Port.A, 7),   // D7

            new Pin(Port.B, 15),  // D8
            new Pin(Port.B, 13),  // D9
            new Pin(Port.B, 4),   // D10
            new Pin(Port.B, 5),   // D11

            new Pin(Port.B, 8),   // D12
            new Pin(Port.B, 9),   // D13
            new Pin(Port.B, 10),  // D14
            new Pin(Port.B, 12),  // D15
    };

    // Maps a color value from src_bits to dst_bits.
    private static int resize_color_channel(int srv_val, int src_bits, int dst_bits) {
        final double ratio = (double) srv_val / ((1 << src_bits) - 1);
        final long result = Math.round(((1 << dst_bits) - 1) * ratio);
        return (int) result;
    }

    // Map a 8 bit rgb332 color to 16 bit rgb565 color.
    private static int color8_to_color16(int c8) {
        final int r3 = (c8 >> 5) & 0x7;
        final int g3 = (c8 >> 2) & 0x7;
        final int b2 = c8 & 0x3;

        final int r5 = resize_color_channel(r3, 3, 5);
        final int g6 = resize_color_channel(g3, 3, 6);
        final int b5 = resize_color_channel(b2, 2, 5);

        final int rgb565 = r5 << 11 | g6 << 5 | b5;
        return rgb565;
    }

    // Given a 16 bits data value and a port, returns the BSSR mask to set
    // the pins of that port.
    private static long value_to_bssr_mask(int uint16_value, Port port) {
        // If WR is on this port, we return a mask that resets it.
        long bssr_bits = (port == WR_PIN.port) ? 1l << (WR_PIN.pin_index + 16) : 0;
        for (int bit = 0; bit < 16; bit++) {
            if (DATA_PINS[bit].port != port) {
                continue;
            }
            final int pin_index = DATA_PINS[bit].pin_index;
            if ((uint16_value & (1 << bit)) == 0) {
                bssr_bits |= 1l << (pin_index + 16);  // set pin low
            } else {
                // Mark for high level
                bssr_bits |= 1l << pin_index;  // set pin high
            }
        }
        return bssr_bits;
    }

    // A common method to output the table data.
    private static void generate_table_data(int uint16_values[], String table_name_prefix, Port port) {
        System.out.printf("const uint32_t %s_port_%s[] = {\n", table_name_prefix, port.name().toLowerCase());
        for (int i = 0; i < 256; i++) {
            long bssr_mask = value_to_bssr_mask(uint16_values[i], port);
            System.out.printf("0x%08x,", bssr_mask);
            if (i % 4 == 3) {
                System.out.printf("  // 0x%02x - 0x%02x\n", i - 3, i);
            }
        }
        System.out.println("};");
    }

    // Direct output table. No color mapping. Needed for TFT commands.
    private static void generate_direct_table(Port port) {
        int values[] = new int[256];
        for (int i = 0; i < 256; i++) {
            values[i] = i;
        }
        generate_table_data(values, "direct_bssr_table", port);
    }

    // Output of color16 mapped from color8.
    private static void generate_color_table(Port port) {
        int values[] = new int[256];
        for (int i = 0; i < 256; i++) {
            values[i] = color8_to_color16(i);;
        }
        generate_table_data(values, "color_bssr_table", port);
    }

    public static void main(String ignored[]) {
        System.out.println("// Pin map:");
        System.out.printf("//   WR    %4s\n", WR_PIN);
        for (int i = 0; i < 16; i++) {
            System.out.printf("//   D%-2d   %4s\n" , i, DATA_PINS[i]);
        }
        for (Port port : Port.values()) {
            System.out.println();
            generate_direct_table(port);
        }
        for (Port port : Port.values()) {
            System.out.println();
            generate_color_table(port);
        }
    }
}
