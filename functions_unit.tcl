#!/usr/bin/expect -f

source functions.tcl

proc assert_equals {expected received} {
    if {[expr [string compare $received $expected] == 0]} {
        puts "Passed"
    } else {
        puts "Failed"
        puts "Expected: $expected"
        puts "Received: $received"
    }
}

proc test_get_class_name {} {
    set class_name [get_class_name "ClassName.java"]
    assert_equals "ClassName" $class_name
}

proc test_get_class_name_with_packages {} {
    set class_name [get_class_name "org/sample/ClassName.java"]
    assert_equals "org.sample.ClassName" $class_name
}

proc test_prepare_stop_clear_position {} {
    set command "stop at Test.java:4"
    set command_parts [split $command]
    set break_position [prepare_stop_clear_position [lindex $command_parts 2]]

    assert_equals "Test:4" $break_position
}
proc test_prepare_position {} {
    set position "Test.java:4"
    set position [prepare_position $position]

    assert_equals "\"Test.java\", 4" $position
}

proc test_class_name_to_file {} {
    set class_name "org.sample.Main"
    set result [class_name_to_file $class_name]
    assert_equals "org/sample/Main" $result
}
test_get_class_name
test_prepare_stop_clear_position
test_prepare_position
test_class_name_to_file
test_get_class_name_with_packages

# vim: filetype=tcl ts=4 sw=4 expandtab
