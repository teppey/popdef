" File: popdef.vim
" Description: List and select definitions in popup window.
" Author: Teppei Hamada <temada@gmail.com>
" Version: 0.4

if exists('g:loaded_popdef')
  finish
endif
let g:loaded_popdef = 1

let s:cpo_save = &cpo
set cpo&vim

command PopDefPython call s:Open('\s*\(def\|class\)\s\+[_a-zA-Z+0-9]\+')
autocmd FileType python nnoremap <silent> <Leader>d :PopDefPython<CR>

command PopDefVim call s:Open('^\s*func')
autocmd FileType vim nnoremap <silent> <Leader>d :PopDefVim<CR>

command PopDefC call s:Open('^[a-zA-Z_]\+.*)\( *{\)\?$')
autocmd FileType c nnoremap <silent> <Leader>d :PopDefC<CR>

" command PopDefCPP call s:Open('^\([a-zA-Z_]\+.*)\( *const\)\?\|\(template .*\)\?class [a-zA-Z_].*\)\( *{\)\?$')
command PopDefCPP call s:Open('^[a-zA-Z_].*$')
autocmd FileType cpp nnoremap <silent> <Leader>d :PopDefCPP<CR>

command PopDefAsciiDoc call s:Open('^=\{1,6} ')
autocmd FileType asciidoc nnoremap <silent> <Leader>d :PopDefAsciiDoc<CR>

func! s:Open(pattern, ...)
    let offset = get(a:, 1, 0)
    let defs = []
    let lnum = 1
    let lmax = line('$')
    let lcur = line('.')
    let lprev = 1
    let firstline = 0
    while lnum <= lmax
        let line = getline(lnum)
        if line =~ a:pattern
            let lnum2 = lnum + offset
            let line2 = getline(lnum2)
            if strlen(line2)
                call add(defs, printf('%5d  %s', lnum2, line2))
                if lcur >= lprev && lcur < lnum2
                    let firstline = len(defs) - 1
                endif
                let lprev = lnum2
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
                \ maxheight: 40,
                \ fixed: 1,
                \ wrap: 1,
                \ firstline: firstline,
                \})
    call win_execute(winid, 'let w:prev_key = ""')
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
