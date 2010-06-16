proc vim_call {command} {
    exec vim --servername VIM -u NONE -U NONE --remote-send ":call $command<CR>"
}

proc do_advance {} {
    expect -re ".*, (\[A-Za-z\]+)\.\[A-Za-z\]*\\(\\), line=(\[0-9\]+)"
    set class_name $expect_out(1,string)
    set line_num $expect_out(2,string)
    vim_call "Jdb_currFileLine(\"$class_name.java\", $line_num)"
    expect "]"
}

proc get_class_name {filename} {
    set filename_parts [split $filename "."]
    return [lindex $filename_parts 0]
}

proc prepare_stop_clear_position {position} {
    set position_parts [split $position ":"]

    set filename [lindex $position_parts 0]
    set linenum [lindex $position_parts 1]
    set class_name [get_class_name $filename]

    return "$class_name:$linenum"
}
proc prepare_position {position} {
    set position_parts [split $position ":"]

    set filename [lindex $position_parts 0]
    set linenum [lindex $position_parts 1]

    return "\"$filename\", $linenum"
}
# vim: filetype=tcl ts=4 sw=4 expandtab
