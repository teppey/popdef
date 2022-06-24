" File: popdef.vim
" Description: Show a list of definitions (function, class, etc) in a popup window.
" Author: Teppei Hamada <temada@gmail.com>
" Version: 0.5

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:popdef_maxheight')
    let g:popdef_maxheight = 40
endif

" TODO: support function
" TODO: support list of patterns or functions
let s:popdef_default_patterns = #{
    \ asciidoc: '^=\{1,6} ',
    \ c:        '^[a-zA-Z_]\+.*)\( *{\)\?$',
    \ cpp:      '^[a-zA-Z_].*$',
    \ python:   '\s*\(def\|class\)\s\+[_a-zA-Z+0-9]\+',
    \ markdown: '^#\{1,6} ',
    \ vim:      '^\s*func',
    \}

" TODO: show message if pattern not found
func! popdef#PopDefDispatch()
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
        let search_mode = getwinvar(a:id, 'search_mode')

        if search_mode
            if a:key is# "\<Enter>"
                let search_pattern = getwinvar(a:id, 'search_pattern')
                call win_execute(a:id, printf("normal /%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal zz')
                call win_execute(a:id, 'let w:search_mode = v:false')
                call popup_setoptions(a:id, #{title: ''})
                return 1
            endif
            if a:key is# "\<BS>" || a:key is# "\<C-h>"
                let search_pattern = getwinvar(a:id, 'search_pattern')
                if !empty(search_pattern)
                    let search_pattern = search_pattern[:-2]
                    call win_execute(a:id, printf("let w:search_pattern = '%s'", search_pattern))
                    call popup_setoptions(a:id, #{title: printf('/%s ', search_pattern)})
                    return 1
                endif
            endif
            if a:key is# "\<C-u>"
                call win_execute(a:id, 'let w:search_pattern = ""')
                call popup_setoptions(a:id, #{title: '/'})
                return 1
            endif
            if a:key =~ '[-.,_/+=%()a-zA-Z0-9 ]'
                let search_pattern = getwinvar(a:id, 'search_pattern') . a:key
                call win_execute(a:id, printf("let w:search_pattern = '%s'", search_pattern))
                call popup_setoptions(a:id, #{title: printf('/%s', search_pattern)})
                return 1
            endif
        endif

        if a:key is# 'n'
            let search_pattern = getwinvar(a:id, 'search_pattern')
            if !empty(search_pattern)
                call win_execute(a:id, printf("normal /%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal zz')
            endif
            return 1
        endif

        if a:key is# 'N'
            let search_pattern = getwinvar(a:id, 'search_pattern')
            if !empty(search_pattern)
                call win_execute(a:id, printf("normal ?%s\<Enter>", search_pattern))
                call win_execute(a:id, 'normal zz')
            endif
            return 1
        endif

        if a:key is# '/'
            call popup_setoptions(a:id, #{title: '/'})
            call win_execute(a:id, 'let w:search_pattern = ""')
            call win_execute(a:id, 'let w:search_mode = v:true')
            return 1
        endif

        " <Home>: Move to first line
        if a:key is# "\<Home>"
            call win_execute(a:id, '1')
            return 1
        endif

        " gg: Move to first line
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

        " <End>, G: Move to last line
        if a:key is# "\<End>" || a:key is# 'G'
            call win_execute(a:id, 'normal G')
            return 1
        endif

        if a:key is# "\<C-F>"
            call win_execute(a:id, "normal \<C-F>")
            return 1
        endif

        if a:key is# "\<C-B>"
            call win_execute(a:id, "normal \<C-B>")
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
                \ maxheight: g:popdef_maxheight,
                \ minheight: min([len(defs), g:popdef_maxheight]),
                \})
    call win_execute(winid, 'let w:prev_key = ""')
    call win_execute(winid, 'let w:search_mode = v:false')
    call win_execute(winid, 'let w:search_pattern = ""')
    if here > 1
        call win_execute(winid, printf('normal %dj', here-1))
    endif
endfunc

let &cpo = s:cpo_save
unlet s:cpo_save
