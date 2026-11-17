module signed_add8_tb;
    reg  signed [7:0] a, b;
    wire signed [7:0] sum;
    wire overflow;

    signed_add8 uut(.a(a), .b(b), .sum(sum), .overflow(overflow));

    initial begin
        $display("   a +    b =  sum | overflow");

        a = 8'd5;    b = 8'd3;    #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd5;   b = -8'd3;   #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = 8'd50;   b = -8'd70;  #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd50;  b = 8'd70;   #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = 8'd0;    b = 8'd0;    #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd1;   b = 8'd1;    #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = 8'd100;  b = 8'd27;   #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = 8'd127;  b = 8'd1;    #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = 8'd100;  b = 8'd100;  #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd128; b = -8'd1;   #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd100; b = -8'd100; #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        a = -8'd128; b = 8'd127;  #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);

        $finish;
    end
endmodule
