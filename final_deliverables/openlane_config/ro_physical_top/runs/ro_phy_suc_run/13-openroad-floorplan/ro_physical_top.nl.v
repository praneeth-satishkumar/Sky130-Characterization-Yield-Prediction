module ro_physical_top (enable,
    ro_out);
 input enable;
 output ro_out;

 wire n0;
 wire n1;
 wire n2;
 wire n3;
 wire n4;

 sky130_fd_sc_hd__buf_2 u_buf (.A(n4),
    .X(ro_out));
 sky130_fd_sc_hd__inv_1 u_inv0 (.A(n0),
    .Y(n1));
 sky130_fd_sc_hd__inv_1 u_inv1 (.A(n1),
    .Y(n2));
 sky130_fd_sc_hd__inv_1 u_inv2 (.A(n2),
    .Y(n3));
 sky130_fd_sc_hd__inv_1 u_inv3 (.A(n3),
    .Y(n4));
 sky130_fd_sc_hd__nand2_1 u_nand (.A(enable),
    .B(n4),
    .Y(n0));
endmodule
