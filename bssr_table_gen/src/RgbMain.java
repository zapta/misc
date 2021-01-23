public class RgbMain {


//    // Map a color channel value between different number of bits..
//    private static int resize_ch(int srv_val, int src_bits, int dst_bits) {
//        final double ratio = (double) srv_val / ((1 << src_bits) - 1);
//        final long result = Math.round(((1 << dst_bits) - 1) * ratio);
//        return (int) result;
//    }
//
//    // Map a 8 bit rgb332 color to 16 bit rgb565
//    private static int rbg332_to_rbg565(int c8) {
//        final int r3 = (c8 >> 5) & 0x7;
//        final int g3 = (c8 >> 2) & 0x7;
//        final int b2 = c8 & 0x3;
//
//        final int r5 = resize_ch(r3, 3, 5);
//        final int g6 = resize_ch(g3, 3, 6);
//        final int b5 = resize_ch(b2, 2, 5);
//
//        final int rgb565 = r5 << 11 | g6 << 5 | b5;
//        return rgb565;
//    }
//
//    // Generates the conversion table.
//    public static void main(String ignored[]) {
//        System.out.println();
//        System.out.printf("const uint16_t rgb332_to_rgb565_table[] = {\n");
//        for (int c8 = 0; c8 < 256; c8++) {
//            System.out.printf("0x%04x,", rbg332_to_rbg565(c8));
//            if (c8 % 4 == 3) {
//                System.out.printf("  // 0x%02x - 0x%02x\n", c8 - 3, c8);
//            }
//        }
//        System.out.println("};");
//    }
}
