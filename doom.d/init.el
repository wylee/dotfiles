;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-
(doom! :input
       :completion
       company            ; the ultimate code completion backend
       ivy                ; a search engine for love and life

       :ui
       doom               ; what makes DOOM look the way it does
       doom-dashboard     ; a nifty splash screen for Emacs
       doom-quit          ; DOOM quit-message prompts when you quit Emacs
       fill-column        ; a `fill-column' indicator
       hl-todo            ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides      ; highlighted indent columns
       modeline           ; snazzy, Atom-inspired modeline, plus API
       ophints            ; highlight the region an operation acts on
       (popup +defaults)  ; tame sudden yet inevitable temporary windows
       tabs               ; a tab bar for Emacs
       treemacs           ; a project drawer, like neotree but cooler
       vc-gutter          ; vcs diff in the fringe
       vi-tilde-fringe    ; fringe tildes to mark beyond EOB
       window-select      ; visually switch windows
       workspaces         ; tab emulation, persistence & separate workspaces

       :editor
       (evil +everywhere) ; come to the dark side, we have cookies
       file-templates     ; auto-snippets for empty files
       fold               ; (nigh) universal code folding
       (format +onsave)   ; automated prettiness
       snippets           ; my elves. They type so I don't have to

       :emacs
       dired              ; making dired pretty [functional]
       electric           ; smarter, keyword-based electric-indent
       undo               ; persistent, smarter undo for your inevitable mistakes
       vc                 ; version-control and Emacs, sitting in a tree

       :term
       vterm              ; the best terminal emulation in Emacs

       :checkers
       syntax             ; tasing you for every semicolon you forget

       :tools
       docker
       editorconfig       ; let someone else argue about tabs vs spaces
       (eval +overlay)    ; run code, run (also, repls)
       lookup             ; navigate your code and its documentation
       lsp
       magit              ; a git porcelain for Emacs
       rgb                ; creating color strings

       :os
       (:if IS-MAC macos) ; improve compatibility with macOS

       :lang
       emacs-lisp         ; drown in parentheses
       json               ; At least it ain't XML
       javascript         ; all(hope(abandon(ye(who(enter(here))))))
       markdown           ; writing docs for people to ignore
       org                ; organize your plain life in plain text
       (python +lsp)      ; beautiful is better than ugly
       sh                 ; she sells {ba,z,fi}sh shells on the C xor
       web                ; the tubes
       yaml               ; JSON, but readable

       :config
       (default +bindings +smartparens))
