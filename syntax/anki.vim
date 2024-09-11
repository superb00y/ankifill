" vim: set fdm=marker foldlevel=0:
"
" Vim syntax file
"
syntax clear
syntax spell toplevel
setlocal conceallevel=2

" prevent embedded language syntaxes from changing 'foldmethod'
if has('folding')
    let s:foldmethod = &l:foldmethod
endif

" HTML
runtime syntax/html.vim
" Conceal tags
syn region htmlEndTag start=+</+ end=+>+ contains=htmlTagN,htmlTagError conceal
syn region htmlTag start=+<[^/]+ end=+>+ contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent,htmlCssDefinition,@htmlPreproc,@htmlArgCluster conceal
"
" Cloze
syn region AnkiCloze start='{{c[0-9]::' end='}}' contains=TOP

syn match insec_space /&nbsp/ conceal cchar=↵
syn match br /<br>/ conceal cchar=↵
syn match img '<img src=[^>]*>' conceal cchar=▨

highlight htmlBold cterm=bold gui=bold
highlight htmlItalic cterm=italic gui=italic
highlight htmlUnderline cterm=underline gui=underline


" Embedded LaTex
unlet b:current_syntax
syn include @LATEX syntax/tex.vim

syn region AnkiMathjaxInlineMath start=/\\(/ end=/\\)/ keepend contains=@LATEX
syn region AnkiMathjaxInlineMath start=/\\\[/ end=/\\\]/ keepend contains=@LATEX

syn region AnkiLatex start=+[latex]+ end=+[/latex]+ keepend contains=@LATEX
syn region AnkiLatexEquation start=+[$]+ end=+[/$]+ keepend contains=@LATEX
syn region AnkiLatexMathEnv start=+[$$]+ end=+[/$$]+ keepend contains=@LATEX


if exists('s:foldmethod') && s:foldmethod !=# &l:foldmethod
    let &l:foldmethod = s:foldmethod
endif

highlight link Conceal MoreMsg
highlight link AnkiDeck PmenuSel
highlight link Suspended ModeMsg
highlight AnkiCloze cterm=italic gui=italic

let b:current_syntax = 'anki'

syntax sync clear
syntax sync minlines=1000
