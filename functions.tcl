#-----FUNCTIONS------------
proc vim_call {command} {
    exec vim --servername VIM -u NONE -U NONE --remote-send ":call $command<CR>"
}

proc class_name_to_file {class_name} {
    set class_name_parts [split $class_name "."]
    return [join $class_name_parts "/"]
}

proc do_advance {} {
    expect {
        -re ".*, (\[A-Za-z.\]+)\\.\[A-Za-z<>\]+\\(\\), line=(\[0-9\]+)" {
            set class_name $expect_out(1,string);
            set line_num $expect_out(2,string);
        }
        "application exited" {
            vim_call "Jdb_interf_close()";
            exit;
        }
    }
    expect "]"
    set file_name [class_name_to_file $class_name]
    vim_call "Jdb_currFileLine(\"$file_name.java\", $line_num)"
}

proc get_class_name {filename} {
    set filename_parts [split $filename "."]
    set preliminary_class_name [lindex $filename_parts 0]
    set preliminary_class_name_parts [split $preliminary_class_name "/"]
    set class_name [join $preliminary_class_name_parts "."]
    return $class_name
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
#-----FUNCTIONS------------
# vim: filetype=tcl ts=4 sw=4 expandtab
