module or_gate_tb;
    reg a, b;
    wire y;

    or_gate uut(.a(a), .b(b), .y(y));

    integer i;
    initial begin
        $display("a b | y");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;
            #10;
            $display("%b %b | %b", a, b, y);
        end
        $finish;
    end
endmodule
