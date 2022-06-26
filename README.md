# popdef

popdef は関数やクラス名のリストをポップアップウィンドウに表示する Vim プラグインです。


ポップアップウィンドウに表示されたリストから選択した行に移動することができます。
デフォルトでは以下のファイルタイプに対応しています: AsciiDoc, C, C++, Python, Markdown, Vim。

関数やクラス定義のパターンを指定することで、簡単に追加することができます。

## Feature

## Requirements

このプラグインはポップアップウィンドウ機能がサポートされたVim 8.2以降のバー
ジョンで動作します。

## Install

autoload/popdef.vim, plugin/popdef.vim を以下のように配置してください。

    ~/.vim/autoload/popdef.vim
    ~/.vim/plugin/popdef.vim

ヘルプファイルが必要であれば、 doc/popdef.txt を以下のように配置して `:helptags doc` を実行してください。

    ~/.vim/doc/popdef.txt

このプラグインは `:PopDef` というコマンドで起動します。
このコマンドの実行をキーマップに割り当てるには、例えば~/.vimrcに次のように設定してください。

    nnoremap <silent> <Leader>d :PopDef<CR>

# Usage

Key bindings:

- `j`: Line downward
- `k`: Line upward
- `H`: Top line of window
- `M`: Middle line of window
- `L`: Bottom line of window
- `<C-f>`: Page down
- `<C-b>`: Page up
- `gg`: Go to first line
- `G`: Go to last line
- `/`: Search mode
- `n`: Search forward
- `N`: Search backward

# Customization
