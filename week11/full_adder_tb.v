module full_adder_tb;
    reg a, b, cin;
    wire sum, cout;

    full_adder uut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    integer i;
    initial begin
        $display("a b cin | sum cout");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i;
            #10;
            $display("%b %b  %b  |  %b    %b", a, b, cin, sum, cout);
        end
        $finish;
    end
endmodule
