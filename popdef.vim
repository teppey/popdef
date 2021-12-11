" File: popdef.vim
" Description: Show a list of definitions (function, class, etc) in a popup window.
" Author: Teppei Hamada <temada@gmail.com>
" Version: 0.5

if exists('g:loaded_popdef')
  finish
endif
let g:loaded_popdef = 1

let s:cpo_save = &cpo
set cpo&vim

command PopDef call s:PopDefDispatchByFiletype()

let s:popdef_default_maxheight = 40

" TODO: support function
" TODO: support list of patterns or functions
let s:popdef_default_patterns = #{
    \ asciidoc: '^=\{1,6} ',
    \ c:        '^[a-zA-Z_]\+.*)\( *{\)\?$',
    \ cpp:      '^[a-zA-Z_].*$',
    \ python:   '\s*\(def\|class\)\s\+[_a-zA-Z+0-9]\+',
    \ vim:      '^\s*func',
    \}

" TODO: show message if pattern not found
func! s:PopDefDispatchByFiletype()
    let ft_var_name = printf('popdef_%s_pattern', &filetype)
    let pattern = get(g:, ft_var_name, '')
    if empty(pattern)
        let pattern = get(s:popdef_default_patterns, &filetype, '')
    endif
    if !empty(pattern)
        call s:PopDefOpen(pattern)
    endif
endfunc

func! s:PopDefOpen(pattern, ...)
    let offset = get(a:, 1, 0)
    let defs = []
    let lnum = 1
    let lmax = line('$')
    let lcur = line('.')
    let here = 1
    while lnum <= lmax
        let line = getline(lnum)
        if line =~ a:pattern
            let lnum2 = lnum + offset
            let line2 = getline(lnum2)
            if strlen(line2)
                call add(defs, printf('%5d  %s', lnum2, line2))
                if lcur - lnum2 >= 0
                    let here = len(defs)
                endif
            endif
        endif
        let lnum += 1
    endwhile

    func! s:MyMenuFilter(id, key)
        " 1行目に移動
        if a:key is# "\<Home>"
            call win_execute(a:id, '1')
            return 1
        endif

        " ggで一行目に移動
        if a:key is# 'g'
            let prev_key = getwinvar(a:id, 'prev_key', '')
            if prev_key == 'g'
                call win_execute(a:id, 'let w:prev_key = ""')
                call win_execute(a:id, '1')
                return 1
            endif
            call win_execute(a:id, 'let w:prev_key = "g"')
            return 1
        endif

        " 最終行に移動
        if a:key is# "\<End>" || a:key is# 'G'
            call win_execute(a:id, 'normal G')
            return 1
        endif

        call win_execute(a:id, 'let w:prev_key = ""')
        return popup_filter_menu(a:id, a:key)
    endfunc

    func! s:Callback(id, result) closure
        if a:result == -1
            return
        endif
        echo defs[a:result-1]
        let lnum = matchlist(defs[a:result-1], '^\s*\(\d\+\)')[1]
        execute printf('silent normal %sG', lnum)
        silent normal zz
    endfunc

    let winid = popup_menu(defs, #{
                \ filter: function('s:MyMenuFilter'),
                \ callback: function('s:Callback'),
                \ maxheight: get(g:, 'popdef_maxheight', s:popdef_default_maxheight),
                \})
    call win_execute(winid, 'let w:prev_key = ""')
    if here > 1
        call win_execute(winid, printf('normal %dj', here-1))
    endif
endfunc

let &cpo = s:cpo_save
unlet s:cpo_save
