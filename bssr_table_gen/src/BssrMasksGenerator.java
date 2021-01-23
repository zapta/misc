//import java.util.HashMap;
//import java.util.Map;
//
//public class BssrMasksGenerator {
//
//    // Map a color channel value between different number of bits..
//    private static int resize_color_channel(int srv_val, int src_bits, int dst_bits) {
//        final double ratio = (double) srv_val / ((1 << src_bits) - 1);
//        final long result = Math.round(((1 << dst_bits) - 1) * ratio);
//        return (int) result;
//    }
//
//    // Map a 8 bit rgb332 color to 16 bit rgb565.
//    private static int color8_to_color16(int c8) {
//        final int r3 = (c8 >> 5) & 0x7;
//        final int g3 = (c8 >> 2) & 0x7;
//        final int b2 = c8 & 0x3;
//
//        final int r5 = resize_color_channel(r3, 3, 5);
//        final int g6 = resize_color_channel(g3, 3, 6);
//        final int b5 = resize_color_channel(b2, 2, 5);
//
//        final int rgb565 = r5 << 11 | g6 << 5 | b5;
//        return rgb565;
//    }
//
//    // If wr_pin is not null, that pin will be forced to 0.
//    private static long color8_to_bssr32(int color16, Map<Integer, Integer> bssr_pin_map, Integer wr_pin) {
//        long bssr_bits = wr_pin == null ? 0 : (1 << wr_pin + 16);
//        for (int bit = 0; bit < 16; bit++) {
//            if (!bssr_pin_map.containsKey(bit)) {
//                continue;
//            }
//            final int pin_index = bssr_pin_map.get(bit);
//            if ((color16 & (1 << bit)) == 0) {
//                bssr_bits |= 1l << (pin_index + 16);  // set pin low
//            } else {
//                // Mark for high level
//                bssr_bits |= 1l << pin_index;  // set pin high
//            }
//        }
//        return bssr_bits;
//    }
//
//    // If wr_pin is not null, that pin will be forced to 0.
//    private static long uint16_to_bssr32(int uint16_value, Map<Integer, Integer> bssr_pin_map) {
//        long bssr_bits = 0;
//        for (int bit = 0; bit < 16; bit++) {
//            if (!bssr_pin_map.containsKey(bit)) {
//                continue;
//            }
//            final int pin_index = bssr_pin_map.get(bit);
//            if ((uint16_value & (1 << bit)) == 0) {
//                bssr_bits |= 1l << (pin_index + 16);  // set pin low
//            } else {
//                // Mark for high level
//                bssr_bits |= 1l << pin_index;  // set pin high
//            }
//        }
//        return bssr_bits;
//    }
//
//    private static void generate_bssr_table(int[] uint16_values, Map<Integer, Integer> bssr_pin_map, String table_name, long forced_bssr) {
//        System.out.printf("const uint32_t %s[] = {\n", table_name);
//        for (int i = 0; i < 256; i++) {
//            int uint16_value = uint16_values[i];
//            long bssr_value = uint16_to_bssr32(uint16_value, bssr_pin_map) | forced_bssr;
//            //final String xxxx = String.format("%08x", bssr_value);
//            System.out.printf("0x%08x,", bssr_value);
//            if (i % 4 == 3) {
//                System.out.printf("  // 0x%02x - 0x%02x\n", i - 3, i);
//            }
//        }
//        System.out.println("};");
//    }
//
//    // Generates the conversion table.
//    public static void main(String ignored[]) {
//        // WR pin is assigned to pin 9 of port A.
//        final int wr_pin_index = 9;
//        final long port_a_forced_bssr = 1l << wr_pin_index + 16;
//        final long port_b_forced_bssr = 0;
//
//        // Mappins of D0-D15 by their assignments to pins of ports A, B
//        // respectivly. Pin assignment is arbitrary.
//        final HashMap<Integer, Integer> port_a_pins = new HashMap<>();
//        port_a_pins.put(0, 0);
//        port_a_pins.put(1, 1);
//        port_a_pins.put(2, 2);
//        port_a_pins.put(3, 3);
//        port_a_pins.put(4, 4);
//        port_a_pins.put(5, 5);
//        port_a_pins.put(6, 6);
//        port_a_pins.put(7, 7);
//
//        final HashMap<Integer, Integer> port_b_pins = new HashMap<>();
//        port_b_pins.put(8, 15);
//        port_b_pins.put(9, 13);
//        port_b_pins.put(10, 4);
//        port_b_pins.put(11, 5);
//        port_b_pins.put(12, 8);
//        port_b_pins.put(13, 9);
//        port_b_pins.put(14, 10);
//        port_b_pins.put(15, 12);
//
//        // Generate tables for direct uint8 writes.
//        {
//            final int direct_values[] = new int[256];
//            for (int i = 0; i < 256; i++) {
//                direct_values[i] = i;
//            }
//          //  generate_bssr_table(direct_values, port_a_pins, "direct_bssr_table_port_a", port_a_forced_bssr);
//            generate_bssr_table(direct_values, port_b_pins, "direct_bssr_table_port_b", port_b_forced_bssr);
//        }
//    }
//
//}
