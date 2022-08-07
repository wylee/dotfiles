if exists('b:current_syntax') | finish |  endif

syn keyword fi_keyword break continue if else match loop
syn keyword fi_keyword block nextgroup=fi_func_start skipwhite
syn keyword fi_keyword jump nextgroup=fi_ident skipwhite

syn match fi_comp_op '\V===\|!===\|==\|!=\|<\|<=\|>\|>='
syn match fi_bool_op '\V&&\|||'
syn match fi_math_op '\V\|*\|/\|+\|-'
syn match fi_inplace_op '\V*=\|/=\|+=\|-='

syn match fi_colon '\V:'
syn match fi_special '\V->'

syn match fi_ident '\v[a-z][a-z0-9_]+' display
syn match fi_special_ident '\v\$[a-z][a-z0-9_]+' display
syn match fi_type_ident '\v[A-Z][A-Za-z0-9]+' display

syn match fi_label '\v^\s*[a-z]+:'

syn match fi_comment '#.*$' display contains=todo
syn keyword fi_todo  TODO FIXME XXX contained

" Types
syn keyword fi_nil nil
syn keyword fi_bool true false
syn keyword fi_builtin_type Type Bool Float Int List Str Tuple

syn match fi_int '\v\d+' display

syn region fi_str start='"' end='"' display
syn region fi_str start='$"' end='"' display

" Highlighting --------------------------------------------------------
hi def link fi_colon Constant
hi def link fi_special Special
hi def link fi_ident Define
hi def link fi_special_ident Special
hi def link fi_type_ident Define
hi def link fi_keyword Keyword
hi def link fi_label Define
hi def link fi_comp_op Operator
hi def link fi_bool_op Operator
hi def link fi_math_op Operator
hi def link fi_inplace_op Operator
hi def link fi_comment Comment
hi def link fi_todo Todo

" Types
hi def link fi_nil Constant
hi def link fi_bool Boolean
hi def link fi_int Number
hi def link fi_str String
hi def link fi_format_str String

let b:current_syntax = 'fi'
