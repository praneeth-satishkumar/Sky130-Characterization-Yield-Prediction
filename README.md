# Sky130 Statistical Characterization Project

This project builds a Sky130 characterization test chip containing ring oscillatotrs, delay chains, and PVT monitor blocks. The goal is to physically implement the design using OpenLane and later use simulation data for yield predicition.

# Current Phyisical Design Status

- Design name: characterization_top
- Tool: Librelane/OpenLane through iic-osic-tools
- PDK: Sky130
- Result: Full RTL-to-layout flow completed
- Timing: 0 setup violations, 0 hold violations, positive slack
- Layout viewed in Klayout
