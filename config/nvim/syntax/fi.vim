if exists('b:current_syntax') | finish |  endif

syn keyword fi_keyword break print
syn keyword fi_keyword block nextgroup=fi_func_start skipwhite
syn keyword fi_keyword jump nextgroup=fi_ident skipwhite

syn match fi_func_start '\V->'

syn match fi_operator '\V==\|!='
syn match fi_operator '\V&&\|||'
syn match fi_operator '\V^\|*\|/\|+\|-'

syn match fi_label '\v^\s*[a-z]+:'

syn match fi_comment '#.*$' display contains=todo
syn keyword fi_todo  TODO FIXME XXX contained

" Types
syn keyword fi_nil nil
syn keyword fi_bool true false

syn match fi_num '\<\d\>' display
syn match fi_num '\<[1-9][_0-9]*\d\>' display
syn match fi_num '\<[1-9][_0-9]*\d[jJ]\>' display

syn region fi_str start='"' end='"' display
syn region fi_str start='$"' end='"' display


" Highlighting --------------------------------------------------------
hi def link fi_keyword Keyword
hi def link fi_func_start Special
hi def link fi_label Identifier
hi def link fi_operator Operator
hi def link fi_comment Comment
hi def link fi_todo Todo

" Types
hi def link fi_nil Constant
hi def link fi_bool Boolean
hi def link fi_num Number
hi def link fi_str String
hi def link fi_format_str String

let b:current_syntax = 'fi'
