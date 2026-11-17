module half_sub_tb;
    reg a, b;
    wire difference, borrow;

    half_sub uut(.a(a), .b(b), .difference(difference), .borrow(borrow));

    integer i;
    initial begin
        $display("a b | difference borrow");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;
            #10;
            $display("%b %b |     %b         %b", a, b, difference, borrow);
        end
        $finish;
    end
endmodule
