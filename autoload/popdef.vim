" File: popdef.vim
" Description: Show the list of definitions (function, class, etc) in the popup window
" Author: Teppei Hamada <temada@gmail.com>
" Version: 1.0

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:popdef_maxheight')
    let g:popdef_maxheight = 40
endif

let s:popdef_default_patterns = #{
    \ asciidoc: '^=\{1,6} ',
    \ c:        '^[a-zA-Z_]\+.*)\( *{\)\?$',
    \ cpp:      '^[a-zA-Z_].*$',
    \ go:       '^\s*func',
    \ markdown: '^#\{1,6} ',
    \ perl:     '^\s*sub\s\+[_a-zA-Z+0-9]\+',
    \ python:   '\s*\(def\|class\)\s\+[_a-zA-Z+0-9]\+',
    \ ruby:     '\s*\(def\|class\|module\)\s',
    \ rust:     '\s*\(fn\|impl\(<.\{-}>\)\?\|trait\|struct\)\s',
    \ scheme:   '(define',
    \ vim:      '^\s*func',
    \}

func! popdef#PopDefDispatch()
    let popdef_patterns = get(g:, 'popdef_patterns', {})
    let pattern = get(popdef_patterns, &filetype, '')
    if empty(pattern)
        let pattern = get(s:popdef_default_patterns, &filetype, '')
    endif
    if empty(pattern)
        call s:ShowError(printf('PopDef: no pattern for filetype=%s', &filetype))
        return
    endif
    call s:PopDefOpen(pattern)
endfunc

func! s:ShowError(message)
    echohl ErrorMsg
    echo a:message
    echohl None
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

    func! s:Callback(id, result) closure
        if a:result == -1
            return
        endif
        echo defs[a:result-1]
        let lnum = matchlist(defs[a:result-1], '^\s*\(\d\+\)')[1]
        execute printf('silent normal! %sG', lnum)
        silent normal zz
    endfunc

    let winid = popup_menu(defs, #{
                \ filter: function('s:MenuFilter'),
                \ callback: function('s:Callback'),
                \ maxheight: g:popdef_maxheight,
                \ minheight: min([len(defs), g:popdef_maxheight]),
                \})
    call setwinvar(winid, 'search_mode', 0)
    call setwinvar(winid, 'search_pattern', '')
    call setwinvar(winid, 'char_stack', [])
    if here > 1
        call win_execute(winid, printf('normal! %dj', here-1))
    endif
endfunc

func! s:MenuFilter(id, key)
    let SearchTitle = {pattern -> printf(' Search: %s ', pattern)}
    let search_mode = getwinvar(a:id, 'search_mode')
    let search_pattern = getwinvar(a:id, 'search_pattern')

    if search_mode
        if a:key is# "\<Enter>"
            try
                call win_execute(a:id, printf("normal! /%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal! zz')
            catch
                call s:ShowError(v:exception)
            endtry
            call setwinvar(a:id, 'search_mode', 0)
            call popup_setoptions(a:id, #{title: ''})
            return 1
        endif
        if a:key is# "\<BS>" || a:key is# "\<C-h>"
            if !empty(search_pattern)
                let search_pattern = search_pattern[:-2]
                call setwinvar(a:id, 'search_pattern', search_pattern)
                call popup_setoptions(a:id, #{title: SearchTitle(search_pattern)})
                return 1
            endif
        endif
        if a:key is# "\<C-u>"
            call setwinvar(a:id, 'search_pattern', '')
            call popup_setoptions(a:id, #{title: SearchTitle('')})
            return 1
        endif
        "if a:key =~ '[-.,_/\^*?|$+=%()a-zA-Z0-9 ]'
        if char2nr(a:key) > 0x1f && char2nr(a:key) < 0x7f
            let search_pattern .= a:key
            call setwinvar(a:id, 'search_pattern', search_pattern)
            call popup_setoptions(a:id, #{title: SearchTitle(search_pattern)})
            return 1
        endif
    endif

    " n: search forward
    if a:key is# 'n'
        if !empty(search_pattern)
            try
                call win_execute(a:id, printf("normal! /%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal! zz')
            catch
                call s:ShowError(v:exception)
            endtry
        endif
        return 1
    endif

    " N: search backward
    if a:key is# 'N'
        if !empty(search_pattern)
            try
                call win_execute(a:id, printf("normal! ?%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal! zz')
            catch
                call s:ShowError(v:exception)
            endtry
        endif
        return 1
    endif

    " /: Enter search mode
    if a:key is# '/'
        call popup_setoptions(a:id, #{title: SearchTitle('')})
        call setwinvar(a:id, 'search_pattern', '')
        call setwinvar(a:id, 'search_mode', 1)
        return 1
    endif

    " <Home>: Move to first line
    if a:key is# "\<Home>"
        call win_execute(a:id, '1')
        return 1
    endif

    " <End>: Move to last line
    if a:key is# "\<End>"
        call win_execute(a:id, 'normal! G')
        return 1
    endif

    " gg: Move to first line
    if a:key is# 'g' && getwinvar(a:id, 'char_stack') == ['g']
        call setwinvar(a:id, 'char_stack', [])
        call win_execute(a:id, '1')
        return 1
    endif

    " G: Goto line <count>, default last line
    if a:key is# 'G'
        let num_arg = str2nr(join(getwinvar(a:id, 'char_stack'), ''))
        if num_arg > 0
            call win_execute(a:id, printf('normal! %dG', num_arg))
        else
            call win_execute(a:id, 'normal! G')
        endif
        call setwinvar(a:id, 'char_stack', [])
        return 1
    endif

    " j: <count> lines downward
    " k: <count lines upward
    " H: Line <count> from top of window
    " M: Middle line of window
    " L: Line <count> from bottom of window
    " <C-F>: Page down
    " <C-B>: Page up
    let command_as_is = ['j', 'k', 'H', 'L', 'M', "\<C-F>", "\<C-B>"]
    if index(command_as_is, a:key) >= 0
        let num_arg = str2nr(join(getwinvar(a:id, 'char_stack'), ''))
        if num_arg < 1
            let num_arg = 1
        endif
        call win_execute(a:id, printf('normal! %d%s', num_arg, a:key))
        call setwinvar(a:id, 'char_stack', [])
        return 1
    endif

    " For `gg` and <count> arg
    if a:key =~ '[g0-9]'
        call setwinvar(a:id, 'char_stack', getwinvar(a:id, 'char_stack') + [a:key])
        return 1
    endif

    return popup_filter_menu(a:id, a:key)
endfunc

let &cpo = s:cpo_save
unlet s:cpo_save
