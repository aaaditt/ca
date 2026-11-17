module full_sub(input a, input b, input borrow_in, output difference, output borrow_out);
    assign difference  = a ^ b ^ borrow_in;
    assign borrow_out  = ((~a) & b) | ((~(a ^ b)) & borrow_in);
endmodule
