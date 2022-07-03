" File: popdef.vim
" Description: Show the list of definitions (function, class, etc) in the popup window
" Author: Teppei Hamada <temada@gmail.com>
" Version: 0.5

if exists('g:loaded_popdef')
  finish
endif
let g:loaded_popdef = 1

let s:cpo_save = &cpo
set cpo&vim

command PopDef call popdef#PopDefDispatch()

let &cpo = s:cpo_save
unlet s:cpo_save
