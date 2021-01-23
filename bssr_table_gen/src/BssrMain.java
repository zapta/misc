//public class BssrMain {
//
//    // bit_indexes order is bit 0 (LSB) to bit 7 (MSB). Wr pin is
//    // optional.
//    private static void generate_table(String name, int[] bit_indexes, Integer wr_pin_bit) {
//        System.out.println();
//        if (wr_pin_bit != null) {
//            System.out.printf("// Also resets wr pin (bit %d)\n", wr_pin_bit);
//        }
//        System.out.printf("const uint32_t bssr_table_%s[] = {\n", name);
//        for (int uint8 = 0; uint8 < 256; uint8++) {
//            // Initial value. Optionally marking the wr bit for low level.
//            long bssr_bits = wr_pin_bit == null ? 0 : (1 << wr_pin_bit + 16);
//            for (int bit = 0; bit < 8; bit++) {
//                final int bit_index = bit_indexes[bit];
//                if ((uint8 & (1 << bit)) == 0) {
//                    bssr_bits |= 1l << (bit_index + 16);  // low level
//                } else {
//                    // Mark for high level
//                    bssr_bits |= 1l << bit_index;  // high level
//                }
//            }
//            System.out.printf("0x%08x,", bssr_bits, uint8);
//            if (uint8 % 4 == 3) {
//                System.out.printf("  // 0x%02x - 0x%02x\n", uint8 - 3, uint8);
//            }
//        }
//        System.out.println("};");
//    }
//
//    public static void main(String ignored[]) {
//        generate_table("lsb_port_a", new int[]{0, 1, 2, 3, 4, 5, 6, 7}, 9);
//        generate_table("msb_port_b", new int[]{15, 13, 4, 5, 8, 9, 10, 12}, null);
//    }
//}
