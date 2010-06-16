let s:bpSet = ""

let s:bpFilename = ""
let s:bpNumber = -1

function Jdb_interf_init(fifo_name, pwd)
  echo "Can not use jdbvim plugin - your vim must have +signs and +clientserver features"
endfunction

if !(has("clientserver") && has("signs"))
  finish
endif

let loaded_jdbvim = 1
let s:having_partner = 0

highlight DebugBreak guibg=darkred guifg=white ctermbg=darkred ctermfg=white
highlight DebugStop guibg=lightgreen guifg=white ctermbg=lightgreen ctermfg=white
sign define breakpoint linehl=DebugBreak
sign define current linehl=DebugStop

function! ClearBreakpoints()
    call MvIterCreate(s:bpSet, "|", "Breaks")
    while MvIterHasNext("Breaks")
        silent call Jdb_command("clear ".MvIterNext("Breaks"))
    endwhile
    call MvIterDestroy("Breaks")
endfunction

function! Jdb_interf_init(fifo_name, pwd)
    if s:having_partner
        echo "Oops, one communication is already running"
        return
    endif
    let s:having_partner=1
    
    let s:fifo_name = a:fifo_name
    execute "cd ". a:pwd

    call s:Jdb_shortcuts()
    let g:loaded_jdbvim_mappings=1

    if !exists(":Jdb")
        command -nargs=+ Jdb        :call Jdb_command(<q-args>, v:count)
    endif
endfunction

function Jdb_interf_close()
    sign unplace *

    let s:bpSet = ""
    let s:having_partner=0
endfunction

function Jdb_bpt(id, file, linenum)
    if !bufexists(a:file)
        execute "bad ".a:file
    endif
    execute "sign unplace ". a:id
    execute "sign place " .  a:id ." name=breakpoint line=".a:linenum." file=".a:file
    let s:bpSet = MvAddElement(s:bpSet, "|", a:file.":".a:linenum)
endfunction

function Jdb_noBpt(id)
    execute "sign unplace ". a:id
    let s:bpSet = MvRemoveElement(s:bpSet, "|", s:bpFilename.":".s:bpLineNumber)
endfunction

function Jdb_currFileLine(file, line)
    if !bufexists(a:file)
        if !filereadable(a:file)
            return
        endif
        execute "e ".a:file
    else
        execute "b ".a:file
    endif
    let s:file=a:file
    execute "sign unplace ". 3
    execute "sign place " .  3 ." name=current line=".a:line." file=".a:file
    execute a:line
    :silent! foldopen!
endf

function Jdb_command(cmd, ...)
  if match (a:cmd, '^\s*$') != -1
    return
  endif
  let suff=""
  if 0<a:0 && a:1!=0
    let suff=" ".a:1
  endif
  silent exec ":redir >>". s:fifo_name ."|echon \"".a:cmd.suff."\n\"|redir END "
endfun

function Jdb_togglebreak(name, line)
    if MvIndexOfElement(s:bpSet, "|", a:name.":".a:line) != -1
        silent call Jdb_command("clear ".a:name.":".a:line)
    else
        silent call Jdb_command("stop at ".a:name.":".a:line)
    endif
    let s:bpFilename = a:name
    let s:bpLineNumber = a:line
endfun

function s:Jdb_shortcuts()
    nmap <unique> <F9>          :call Jdb_togglebreak(bufname("%"), line("."))<CR>
    nmap <unique> <C-F5>        :Jdb run<CR>
    nmap <unique> <F7>          :Jdb step<CR>
    nmap <unique> <F8>          :Jdb next<CR>
    nmap <unique> <F6>          :Jdb finish<CR>
    nmap <unique> <F5>          :Jdb continue<CR>
    vmap <unique> <C-P>         "gy:Jdb print <C-R>g<CR>
    nmap <unique> <C-P>         :call Jdb_command("print ".expand("<cword>"))<CR> 
endfunction
