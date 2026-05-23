# Create timestamped reports folder
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set reports_dir "./reports/$timestamp"
file mkdir $reports_dir

# Optionally also keep a "latest" symlink/folder
set latest_dir "./reports/latest"
file mkdir $latest_dir

foreach {cmd filename} {
    report_timing_summary    timing_summary.rpt
    report_utilization       utilization.rpt
    report_power             power.rpt
    report_drc               drc.rpt
    report_clock_interaction clock_interaction.rpt
    report_cdc               cdc.rpt
    report_methodology       methodology.rpt
} {
    $cmd -file "$reports_dir/$filename"
    $cmd -file "$latest_dir/$filename"   ;# overwrite latest every run
}

puts "Reports written to: $reports_dir"