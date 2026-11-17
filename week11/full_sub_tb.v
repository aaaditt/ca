module full_sub_tb;
    reg a, b, bin;
    wire difference, bout;

    full_sub uut(.a(a), .b(b), .borrow_in(bin), .difference(difference), .borrow_out(bout));

    integer i;
    initial begin
        $display("a b bin | difference bout");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, bin} = i;
            #10;
            $display("%b %b  %b  |     %b       %b", a, b, bin, difference, bout);
        end
        $finish;
    end
endmodule
