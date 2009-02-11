" Vim file to detect ruby/rails file types
"
" Maintainer:	Tj Vanderpoel <bougy.man@gmail.com>
" Last Change:	2008 Oct 10

" only load once
if exists("b:did_load_ruby_filetypes")
  finish
endif
let b:did_load_ruby_filetypes = 1

augroup filetypedetect

" Ruby
au BufNewFile,BufRead *.rb,*.rbw,*.gem,*.gemspec,*.rjs,*.rxml	setf ruby
au BufNewFile,BufRead *.rb,*.rbw,*.gem,*.gemspec,*.rjs	iab def def<CR>end<UP>

" ERuby
au BufNewFile,BufRead *.rhtml,*.erb	setf eruby


" Ruby Makefile
au BufNewFile,BufRead [rR]akefile*		setf ruby
au BufNewFile,BufRead [rR]akefile*		iab def def<CR>end<UP>

augroup END
