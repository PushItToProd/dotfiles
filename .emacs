(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

(unless (package-installed-p 'evil)
  (package-install 'evil))
(unless (package-installed-p 'spacemacs-theme)
  (package-install 'spacemacs-theme))
(unless (package-installed-p 'ledger-mode)
  (package-install 'ledger-mode))
(add-to-list 'load-path "~/.emacs.d/lib")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(require 'yaml-mode)

(require 'key-chord)
(key-chord-mode 1)
(require 'key-seq)

(setq evil-shift-width 4)
(setq evil-want-C-u-scroll t)
(require 'evil)
(key-seq-define evil-insert-state-map "jk" 'evil-normal-state)
(key-seq-define evil-visual-state-map "jk" 'evil-normal-state)
(key-seq-define evil-normal-state-map ",o" 'find-file)
(key-seq-define evil-normal-state-map ",a" 'previous-buffer)
(key-seq-define evil-normal-state-map ",d" 'next-buffer)
(define-key evil-motion-state-map "H" "^")
(define-key evil-motion-state-map "L" "$")
(evil-mode 1)

(global-linum-mode t)
(global-hl-line-mode +1)
;(if (display-graphic-p)
;    (load-theme 'dracula t)
;  (set-face-background hl-line-face "darkblue"))
(load-theme 'spacemacs-dark t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-buffer-menu t)

; highlight whitespace and long lines
; based on https://gist.github.com/RayRacine/3794795
; (defun setup-whitespace ()
;     "Handle highlighting long lines and whitespace."
;     (require 'whitespace)
;     (custom-set-faces
;     '(my-carriage-return-face ((((class color)) (:background "blue"))) t)
;     '(my-tab-face ((((class color)) (:background "green"))) t)
;     )
;     (add-hook 'font-lock-mode-hook
;             (function (lambda ()
;                         (setq font-lock-keywords
;                                 (append font-lock-keywords
;                                         '(("\r" (0 'my-carriage-return-face t))
;                                         ("\t" (0 'my-tab-face t))))))))
;     (setq whitespace-style '(face trailing tab-mark lines-tail)
;         whitespace-line-column 80)
;     (global-whitespace-mode +1)
;     (setq whitespace-global-modes '(not go-mode))
;     )
; (add-hook 'prog-mode-hook (lambda () (setup-whitespace)))
(require 'whitespace)
(setq whitespace-style '(face empty trailing lines-tail)
      whitespace-line-column 80)
(setq whitespace-global-modes '(not go-mode))
; whitespace styles for Go and SQL
(add-hook 'go-mode-hook
          (lambda ()
            (setq whitespace-style '(face empty trailing lines-tail))
            (setq tab-width 4)
            (setq indent-tabs-mode 1)))
(add-hook 'sql-mode-hook
          (lambda ()
            (setq tab-width 4)
            (setq indent-tabs-mode nil)))

(setq ring-bell-function 'ignore)
(setq fill-column 80)
(add-hook 'find-file-hook (lambda () (ruler-mode 1)))

(setq show-paren-delay 0)
(show-paren-mode 1)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(when window-system
  (set-frame-size (selected-frame) 81 50))

(require 'org)
(setq org-default-notes-file (concat org-directory "/capture.org"))
(define-key global-map "\C-cc" 'org-capture)
(setq org-refile-use-outline-path 'file)

; Stop emacs from cluttering the filesystem with backup files.
; https://www.emacswiki.org/emacs/BackupDirectory
(setq
 backup-by-copying t
 backup-directory-alist `((".*" . ,temporary-file-directory))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t
 auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq ledger-mode-should-check-version nil
      ledger-report-links-in-register nil
      ledger-bindary-path "hledger")
(add-to-list 'auto-mode-alist '("\\.journal\\'" . ledger-mode))
(add-hook 'ledger-mode-hook (lambda () (auto-revert-mode)))

(add-hook 'python-mode-hook
          #'(lambda () (setq electric-indent-mode nil)))

;(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq css-indent-offset 2)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("a2cde79e4cc8dc9a03e7d9a42fabf8928720d420034b66aecc5b665bbf05d4e9" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "cdb4ffdecc682978da78700a461cdc77456c3a6df1c1803ae2dd55c59fa703e3" "f8cf128fa0ef7e61b5546d12bb8ea1584c80ac313db38867b6e774d1d38c73db" default)))
 '(org-export-backends (quote (ascii html icalendar latex md)))
 '(package-selected-packages
   (quote
    (haskell-mode monokai-theme spacemacs-theme zenburn-theme rust-mode terraform-mode go-mode ansible markdown-mode ledger-mode tide evil)))
 '(scroll-conservatively 10000)
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 120 :width normal)))))

; make scrolling nicer
(setq scroll-conservatively most-positive-fixnum)

; config for writing
(progn
  (defun xah-use-variable-width-font ()
    "Set current buffer to use variable width font."
    (variable-pitch-mode 1))
  (add-hook 'rst-mode-hook 'xah-use-variable-width-font))

(add-hook 'org-mode-hook
          (lambda () (visual-line-mode)))
(add-hook 'rst-mode-hook
          (lambda () (visual-line-mode)))
(add-hook 'markdown-mode-hook
          (lambda () (visual-line-mode)))

(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-10"))

(setq visible-bell 1)

; bats support
(add-to-list 'auto-mode-alist '("\\.bats\\'" . sh-mode))
(add-hook 'sh-mode-hook
          (lambda ()
            (if (string-match "\\.bats$" buffer-file-name)
                (sh-set-shell "bash")
              (if (string-match "\\.sh$" buffer-file-name)
                  (sh-set-shell "bash")))))

(setq sh-basic-offset 2)

(add-to-list 'load-path "~/.emacs.d/rust-mode")
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

; This doesn't actually do anything afaict.  TODO: figure out how to
; make org mode open Firefox instead of Chromium.
(setq browser-url-browser-function 'browse-url-firefox)
