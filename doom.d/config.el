;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(setq user-full-name "Wyatt Baldwin" user-mail-address "self@wyattbaldwin.com")
(setq doom-font (font-spec :family "Monaco" :size 14))
(setq doom-theme 'doom-one)
(setq org-directory "~/org/")
(setq display-line-numbers-type t)
(add-hook 'after-init-hook 'global-company-mode)
