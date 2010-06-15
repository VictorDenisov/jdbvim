puts [regexp  ".*\\(\\), line=(\[0-9\]+).*" "Step completed: \"thread=main\", Test.main(), line=4 bci=8" whole a b]
puts $a
#puts [exec vim --servername VIM -u NONE -U NONE --remote-send ":call Jdb_currFileLine(\"Test.java\", 3)<CR>"]
