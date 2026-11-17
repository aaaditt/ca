module half_adder_tb;
    reg a, b;
    wire sum, carry;

    half_adder uut(.a(a), .b(b), .sum(sum), .carry(carry));

    integer i;
    initial begin
        $display("a b | sum carry");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;
            #10;
            $display("%b %b |  %b    %b", a, b, sum, carry);
        end
        $finish;
    end
endmodule
