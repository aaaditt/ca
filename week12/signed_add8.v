// 1-bit full adder (building block)
module full_adder(input a, input b, input cin, output sum, output cout);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

// 8-bit signed (2's complement) adder: sum = a + b
// Built as a ripple-carry chain of 8 full adders.
// overflow = 1 when the true result does not fit in 8 signed bits (-128..127)
module signed_add8(input [7:0] a, input [7:0] b, output [7:0] sum, output overflow);
    wire c1, c2, c3, c4, c5, c6, c7, c8;

    full_adder fa0(.a(a[0]), .b(b[0]), .cin(1'b0), .sum(sum[0]), .cout(c1));
    full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1),   .sum(sum[1]), .cout(c2));
    full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2),   .sum(sum[2]), .cout(c3));
    full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3),   .sum(sum[3]), .cout(c4));
    full_adder fa4(.a(a[4]), .b(b[4]), .cin(c4),   .sum(sum[4]), .cout(c5));
    full_adder fa5(.a(a[5]), .b(b[5]), .cin(c5),   .sum(sum[5]), .cout(c6));
    full_adder fa6(.a(a[6]), .b(b[6]), .cin(c6),   .sum(sum[6]), .cout(c7));
    full_adder fa7(.a(a[7]), .b(b[7]), .cin(c7),   .sum(sum[7]), .cout(c8));

    // signed overflow: carry into the sign bit differs from carry out of it
    assign overflow = c7 ^ c8;
endmodule
