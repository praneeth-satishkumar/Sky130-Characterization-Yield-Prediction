module delay_chain_physical_top (
	input wire in,
	output wire out
);

	wire n0;
	wire n1;
        wire n2;
        wire n3;
        wire n4;
        wire n5;
        wire n6;
        wire n7;

	sky130_fd_sc_hd__buf_2 u0 (.A(in), .X(n0));
        sky130_fd_sc_hd__buf_2 u1 (.A(n0), .X(n1));
        sky130_fd_sc_hd__buf_2 u2 (.A(n1), .X(n2));
        sky130_fd_sc_hd__buf_2 u3 (.A(n2), .X(n3));
        sky130_fd_sc_hd__buf_2 u4 (.A(n3), .X(n4));
        sky130_fd_sc_hd__buf_2 u5 (.A(n4), .X(n5));
        sky130_fd_sc_hd__buf_2 u6 (.A(n5), .X(n6));
        sky130_fd_sc_hd__buf_2 u7 (.A(n6), .X(n7));
	sky130_fd_sc_hd__buf_2 u8 (.A(n7), .X(out));

endmodule
