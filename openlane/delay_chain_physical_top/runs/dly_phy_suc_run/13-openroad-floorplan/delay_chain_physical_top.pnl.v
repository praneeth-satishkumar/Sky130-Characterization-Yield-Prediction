module delay_chain_physical_top (in,
    out);
 input in;
 output out;

 wire n0;
 wire n1;
 wire n2;
 wire n3;
 wire n4;
 wire n5;
 wire n6;
 wire n7;
 wire VPWR;
 wire VGND;

 sky130_fd_sc_hd__buf_2 u0 (.A(in),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n0));
 sky130_fd_sc_hd__buf_2 u1 (.A(n0),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n1));
 sky130_fd_sc_hd__buf_2 u2 (.A(n1),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n2));
 sky130_fd_sc_hd__buf_2 u3 (.A(n2),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n3));
 sky130_fd_sc_hd__buf_2 u4 (.A(n3),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n4));
 sky130_fd_sc_hd__buf_2 u5 (.A(n4),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n5));
 sky130_fd_sc_hd__buf_2 u6 (.A(n5),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n6));
 sky130_fd_sc_hd__buf_2 u7 (.A(n6),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(n7));
 sky130_fd_sc_hd__buf_2 u8 (.A(n7),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(out));
endmodule
