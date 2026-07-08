drc off
gds read $::env(GDS)
load ro_physical_top
select top cell

extract do local
extract all

ext2spice lvs
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice subcircuit top on
ext2spice

quit


