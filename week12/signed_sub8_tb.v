module signed_sub8_tb;
    reg  signed [7:0] a, b;
    wire signed [7:0] diff;
    wire overflow;

    signed_sub8 uut(.a(a), .b(b), .diff(diff), .overflow(overflow));

    initial begin
        $display("   a -    b = diff | overflow");

        a = 8'd5;    b = 8'd3;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd3;    b = 8'd5;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = -8'd5;   b = -8'd3;   #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = -8'd5;   b = 8'd3;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd50;   b = -8'd70;  #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd0;    b = 8'd0;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd0;    b = 8'd1;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd100;  b = 8'd27;   #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd100;  b = -8'd100; #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = -8'd128; b = 8'd1;    #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = -8'd100; b = 8'd100;  #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = 8'd127;  b = -8'd1;   #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);
        a = -8'd128; b = -8'd128; #10; $display("%4d - %4d = %4d |    %b", a, b, diff, overflow);

        $finish;
    end
endmodule
