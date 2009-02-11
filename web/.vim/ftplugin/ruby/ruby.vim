fun! LoadRubyTmp()
  let b:fname = substitute(expand("%"), "/", "{slash}", "g")
  let b:filename = "/tmp/ride." . $STY . "->" . $WINDOW . "->" . b:fname
  " echo b:filename
  execute "write! " . b:filename
  call system("screen -p 1 -X stuff \"load " . '\"' . b:filename . '\"' . "\n\"")
  call system("screen -X select 1")
endfun
nmap <F12> :call LoadRubyTmp()<CR>
