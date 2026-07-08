read_liberty $::env(LIB_FILE)
read_verilog $::env(NETLIST_FILE)
link_design characterization_top

read_sdc $::env(SDC_FILE)

report_checks -path_delay max > $::env(OUT_DIR)/setup_timing.rpt
report_checks -path_delay min > $::env(OUT_DIR)/hold_timing.rpt
report_worst_slack -max > $::env(OUT_DIR)/setup_slack.rpt
report_worst_slack -min > $::env(OUT_DIR)/hold_slack.rpt
report_tns > $::env(OUT_DIR)/tns.rpt
report_wns > $::env(OUT_DIR)/wns.rpt
