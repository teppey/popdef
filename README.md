# Popdef

Popdef is a Vim plugin that displays a list of function and class names in
the popup window. You can move to the selected line from the displayed
list. It is useful to get an overview of the source code.

![popdef](popdef.png)

By default, the following file types are supported: AsciiDoc, C, C++, Go,
Markdown, Perl, Python, Ruby, Rust, Scheme, Vim. File types not supported by
default can be easily added. See the description of Variables section in
[doc/popdef.txt](doc/popdef.txt) for details.


## Requirements

This plugin works with Vim 8.2 or later versions that support the popup window.


## Install

Place `autoload/popdef.vim` and `plugin/popdef.vim` into runtime directory.

Unix/macOS:

    ~/.vim/autoload/popdef.vim
    ~/.vim/plugin/popdef.vim

Windows:

    %USERPROFILE%\vimfiles\autoload\popdef.vim
    %USERPROFILE%\vimfiles\plugin\popdef.vim

If you need a help file, place `doc/popdef.txt` into runtime directory and run
`:helptags ~/.vim/doc` (Unix/macOS) or `:helptags %USERPROFILE%\vimfiles\doc`
(Windows).

This plugin is invoked with the command `:PopDef`. To assign the execution of
this command to a keymap, for example, set the following in ~/.vimrc:

    nnoremap <silent> <Leader>d :PopDef<CR>

## Key Mapping

- x, CTRL-C, \<Esc>: Close the popup window
- \<Space>, \<Enter>: Close the popup window and jump to selected line
- j: \<count> line downward
- k: \<count> line upward
- H: Line \<count> from top of window
- M: Middle line of window
- L: Line \<count> from bottom of window
- CTRL-F: Page down
- CTRL-B: Page up
- gg: Go to first line
- G: Goto line \<count>, default last line
- /: Forward search
- ?: Backward search
- n: Repeat the latest `/` or `?`
- N: Repeat the latest `/` or `?` in opposite direction
- zt: Cursor line to top of window
- zz: Cursor line to center of window
- zb: Cursor line to bottom of window
