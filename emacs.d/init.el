;; package config ------------------------------------------------------

(require 'package)

(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents) (package-refresh-contents))
(unless (package-installed-p 'use-package) (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; end package config --------------------------------------------------


;; packages ------------------------------------------------------------

(use-package
  better-defaults
  :ensure t)

(use-package
  evil
  :ensure t
  :config
  (evil-mode 1)
  (setq evil-ex-substitute-global t))

(use-package
  flycheck
  :ensure t)

(use-package
  hide-mode-line
  :ensure t
  :defer t)

(use-package
  material-theme
  :ensure t)

(use-package
  projectile
  :ensure t)

;; projects
(use-package treemacs
  :ensure t
  :defer t
  :config
  (setq
    treemacs-no-png-images t
    treemacs-width 24)
  :bind ("C-c t" . treemacs))

;; python
(use-package
  elpy
  :ensure t
  :init
  (elpy-enable)
  :config
  (setq elpy-rpc-virtualenv-path 'current)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  :hook (elpy-mode . flycheck-mode))

(use-package inferior-python-mode
  :ensure nil
  :hook (inferior-python-mode . hide-mode-line-mode))

(use-package blacken
  :ensure t
  :defer t
  :hook (python-mode . blacken-mode))

;; end packages --------------------------------------------------------


;; basic config --------------------------------------------------------

(column-number-mode 1)
(desktop-save-mode 1)
(global-display-fill-column-indicator-mode 72)
(global-linum-mode t)
(line-number-mode 1)
(load-theme 'material t)
(prefer-coding-system 'utf-8)
(show-paren-mode 1)

(setq backup-inhibited t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq standard-indent 4)
(setq transient-mark-mode t)

(add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; hide toolbar
(progn
  (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (scroll-bar-mode -1))

;; end basic config ----------------------------------------------------


;; automatically updated -----------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(projectile use-package magit hide-mode-line helm-lsp evil blacken)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
