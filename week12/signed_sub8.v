// 1-bit full subtractor (building block)
module full_sub(input a, input b, input borrow_in, output difference, output borrow_out);
    assign difference = a ^ b ^ borrow_in;
    assign borrow_out = ((~a) & b) | ((~(a ^ b)) & borrow_in);
endmodule

// 8-bit signed (2's complement) subtractor: diff = a - b
// Built as a ripple-borrow chain of 8 full subtractors.
// overflow = 1 when the true result does not fit in 8 signed bits (-128..127)
module signed_sub8(input [7:0] a, input [7:0] b, output [7:0] diff, output overflow);
    wire br1, br2, br3, br4, br5, br6, br7, br8;

    full_sub fs0(.a(a[0]), .b(b[0]), .borrow_in(1'b0), .difference(diff[0]), .borrow_out(br1));
    full_sub fs1(.a(a[1]), .b(b[1]), .borrow_in(br1),  .difference(diff[1]), .borrow_out(br2));
    full_sub fs2(.a(a[2]), .b(b[2]), .borrow_in(br2),  .difference(diff[2]), .borrow_out(br3));
    full_sub fs3(.a(a[3]), .b(b[3]), .borrow_in(br3),  .difference(diff[3]), .borrow_out(br4));
    full_sub fs4(.a(a[4]), .b(b[4]), .borrow_in(br4),  .difference(diff[4]), .borrow_out(br5));
    full_sub fs5(.a(a[5]), .b(b[5]), .borrow_in(br5),  .difference(diff[5]), .borrow_out(br6));
    full_sub fs6(.a(a[6]), .b(b[6]), .borrow_in(br6),  .difference(diff[6]), .borrow_out(br7));
    full_sub fs7(.a(a[7]), .b(b[7]), .borrow_in(br7),  .difference(diff[7]), .borrow_out(br8));

    // signed overflow: borrow into the sign bit differs from borrow out of it
    assign overflow = br7 ^ br8;
endmodule
