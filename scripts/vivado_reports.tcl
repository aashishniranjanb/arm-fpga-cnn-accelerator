# Vivado Report Generation Script
# Usage: source this script after synthesis in Vivado Tcl console
#
# vivado -mode batch -source vivado_reports.tcl
# OR
# In Vivado Tcl console: source scripts/vivado_reports.tcl

# Open the synthesized design
open_run synth_1

# Generate utilization report
puts "Generating utilization report..."
report_utilization -hierarchical -file utilization.rpt

# Generate timing summary
puts "Generating timing report..."
report_timing_summary -file timing.rpt

# Generate power estimate
puts "Generating power report..."
report_power -file power_estimate.rpt

# Display summary to console
puts "============================================"
puts "Report Generation Complete"
puts "============================================"
puts "Generated files:"
puts "  - utilization.rpt"
puts "  - timing.rpt"  
puts "  - power_estimate.rpt"
puts "============================================"

# Optional: Generate additional reports
# report_utilization -hierarchical
# report_timing -max_paths 10
# report_clock_utilization
