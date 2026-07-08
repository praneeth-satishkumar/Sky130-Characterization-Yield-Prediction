# Demo Script

## 1. Project Goal
This project characterizes a Sky130 ASIC design using RTL, physical implementation, STA timing, SPICE simulation, and yield estimation.

## 2. Architecture
Show the characterization blocks:
- RO measurement
- Delay-chain measurement
- PVT classification
- Timing/corner analysis

## 3. Physical Implementation
Show the full-chip KLayout screenshot.
Mention:
- LibreLane/OpenLane completed
- DRC passed
- LVS passed
- STA timing passed

## 4. Ring Oscillator Characterization
Show:
- RO physical layout
- SS/TT/FF SPICE waveforms
- TT post-layout extracted RO waveform

Key result:
- SS: 2.075 GHz
- TT pre-layout: 4.073 GHz
- TT post-layout extracted: 1.9768 GHz
- FF: 6.380 GHz

## 5. Delay-Chain Characterization
Show:
- Delay-chain layout
- Post-layout SPICE waveform

Key result:
- TT rise delay: 988.95 ps
- TT fall delay: 1.21034 ns

## 6. PVT and STA Sweeps
Show voltage/temperature/process slack plots.
Mention:
- SS low-voltage cases failed timing
- Higher voltage improved setup slack
- FF had tightest hold slack

## 7. Yield Estimate
Show final yield table.
Mention:
- Overall STA sweep: 15/19 = 78.9%
- Physical RO SPICE sweep: 3/3 = 100%
- Post-layout extracted RO: 1/1 = 100%
- Physical delay-chain SPICE: 2/2 = 100%

## 8. Limitations
Results are based on Sky130 STA, layout, and SPICE simulation.
True silicon-measured data requires fabrication and tapeout.
This is not full Monte Carlo silicon yield.
