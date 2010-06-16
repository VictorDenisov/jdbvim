#!/usr/bin/expect -f

source functions.tcl

#---MAIN SECTION-------------------

if {$argc < 1} {
    puts "We expect at least one argument"
    exit
}

if {[file exists channel.fifo] == 0} {
    exec mkfifo --mode=600 channel.fifo
}

vim_call "Jdb_interf_init(\"channel.fifo\", \".\")"
set breaks_id 0
set test_class [lindex $argv 0]

spawn jdb $test_class
expect ">"
send "stop in $test_class.main\n"
expect ">"
send "run\n"

do_advance

proc process_command {command} {
    global breaks_id
    global breaks
    set command_parts [split $command]
    set head_command [lindex $command_parts 0]
    append command "\n"
    if {[expr [string compare $head_command "quit"] == 0]} {
        send $command
        vim_call "Jdb_interf_close()"
        exit
    } elseif {[expr [string compare $head_command "clear"] == 0]} {
        set break_position [prepare_stop_clear_position [lindex $command_parts 1]]
        set break_id $breaks($break_position)
        unset breaks($break_position)
        send "clear $break_position\n"
        expect "]"
        vim_call "Jdb_noBpt($break_id)"
    } elseif {[expr [string compare $head_command "stop"] == 0]} {
        #we expect only the following format of stop command: stop at Test.java:6
        incr breaks_id

        set position [lindex $command_parts 2]
        set break_position [prepare_stop_clear_position $position]
        set position [prepare_position $position]

        set breaks($break_position) $breaks_id
        send "stop at $break_position\n"
        expect "]"
        vim_call "Jdb_bpt($breaks_id, $position)"
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
        expect "]"
    }
}

set breaks("dumb:dumb") "-1"

while {1} {
    set f [open "channel.fifo"]
    set s [gets $f]
    process_command $s
    close $f
}

vim_call("Gdb_interf_close()");

vwait _dumb_var_
# vim: filetype=tcl ts=4 sw=4 expandtab
