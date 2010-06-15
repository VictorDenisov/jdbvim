#!/usr/bin/expect -f

#---FUNCTIONS SECTION--------------
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
#---END FUNCTIONS SECTION----------

#---MAIN SECTION-------------------

if {$argc < 1} {
    puts "We expect at least one argument"
    exit
}

if {[file exists channel.fifo] == 0} {
    exec mkfifo --mode=600 channel.fifo
}
set log [open "log.txt" w]

vim_call "Jdb_interf_init(\"channel.fifo\", \".\""

set test_class [lindex $argv 0]

spawn jdb $test_class
expect ">"
send "stop in $test_class.main\n"
expect ">"
send "run\n"

do_advance

proc process_command {log command} {
    set command_parts [split $command]
    set head_command [lindex $command_parts 0]
    append command "\n"
    if {[expr [string compare $head_command "stop"] == 0]} {
        send $command
        expect
    } elseif {[expr [string compare $head_command "quit"] == 0]} {
        send $command
        expect
        exit
    } elseif {[expr [string compare $head_command "step"] == 0]} {
        send $command
        do_advance
    } elseif {[expr [string compare $head_command "next"] == 0]} {
        send $command
        do_advance
    } elseif {[expr [string compare $head_command "cont"] == 0]} {
        send $command
        do_advance
    } elseif {[expr [string compare $head_command "exit"] == 0]} {
        exit
    } else {
        send $command
        expect
    }
}

while {1} {
    set f [open "channel.fifo"]
    set s [gets $f]
    process_command $log $s
    close $f
}

vwait _dumb_var_
# vim: filetype=tcl ts=4 sw=4 expandtab
