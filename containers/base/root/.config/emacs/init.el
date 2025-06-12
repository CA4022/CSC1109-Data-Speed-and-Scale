;;; init.el --- CSS1109 Emacs Configuration

;;; Commentary:
;;
;; A general, not very personalized or opinionated setup for Emacs.
;; It is intended as a general environment for students who prefer to use Emacs.
;; This configuration file bootstraps 'straight.el' for package management
;; and sets up a modern environment for development.

;;; Code:
;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)

;; Make use-package use straight.el by default
(use-package straight
  :custom (straight-use-package-by-default t))

;; Install the catpuccin theme
(use-package catppuccin-theme
  :straight t
  :config
  (setq catppuccin-flavor 'mocha)

  (load-theme 'catppuccin t))

;; Completion and selection frameworks
(use-package vertico
  :straight t
  :init (vertico-mode 1))

(use-package orderless
  :straight t
  :custom (completion-styles '(orderless)))

(use-package embark-consult
  :straight t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package embark
  :straight t
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (define-key global-map (kbd "C-.") 'embark-act)
  (define-key global-map (kbd "C-;") 'embark-dwim)
  (define-key global-map (kbd "C-h B") 'embark-bindings)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package consult
  :straight t)

(use-package marginalia
  :straight t
  :config
  (marginalia-mode))

;; Navigation and editing enhancements
(use-package ace-window
  :straight t
  :bind (("M-o" . ace-window)))

(use-package avy
  :straight t
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-line)))

(use-package expand-region
  :straight t
  :bind (("C-=" . er/expand-region)))

(use-package crux
  :straight t)

;; Language Server Protocol (LSP) support
(use-package eglot
  :straight t)

;; Project and file management
(use-package projectile
  :straight t
  :init (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package recentf
  :init (recentf-mode 1))

(use-package dashboard
  :straight t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-banner-logo-title "Hello, student.")
  (setq dashboard-items '((recentf   . 5)
                         (projects  . 5)
                         (bookmarks . 5)))
  (setq dashboard-footer-messages '("\"Good ol' C-x M-c M-butterfly\" - XKCD 378")))

(use-package editorconfig
  :straight t
  :init (editorconfig-mode 1))

;; Version control
(use-package magit
  :straight t
  :bind (("C-x g" . magit-status)))

(use-package diff-hl
  :straight t
  :init (global-diff-hl-mode 1))

(use-package git-timemachine
  :straight t)

;; Syntax checking and linting
(use-package flycheck
  :straight t
  :init (global-flycheck-mode 1))

;; Save minibuffer history
(use-package savehist
  :init (savehist-mode 1))

;; Set up some sensible Emacs defaults
(setq inhibit-startup-message t
      ring-bell-function 'ignore
      backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-default nil)

;; Enable line numbers
(global-display-line-numbers-mode 1)
