; Package installation
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

; Ensure we only package-refresh-contents once
(setq packages-refreshed-during-startup nil)
(defun package-refresh-once ()
  (unless packages-refreshed-during-startup
    (package-refresh-contents)
    (setq packages-refreshed-during-startup t)))

; Install pkg if it's not present, refreshing the packages first
; if they aren't already.
(defun my-package-install (pkg)
  (unless (package-installed-p pkg)
    (package-refresh-once)
    (package-install pkg)))

(my-package-install 'evil)
(my-package-install 'spacemacs-theme)
(my-package-install 'ledger-mode)
(my-package-install 'markdown-mode)
(my-package-install 'ivy)
(my-package-install 'ivy-rich)
(my-package-install 'all-the-icons-ivy-rich)
(my-package-install 'ivy-posframe)
(my-package-install 'counsel)

(add-to-list 'load-path "~/.emacs.d/lib")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(require 'yaml-mode)

(require 'key-chord)
(key-chord-mode 1)
(require 'key-seq)
(require 'space-chord)

(setq evil-shift-width 4)
(setq evil-want-C-u-scroll t)
(require 'evil)
(key-seq-define evil-insert-state-map "jk" 'evil-normal-state)
(key-seq-define evil-visual-state-map "jk" 'evil-normal-state)
(key-seq-define evil-normal-state-map ",o" 'find-file)
(key-seq-define evil-normal-state-map ",a" 'previous-buffer)
(key-seq-define evil-normal-state-map ",d" 'next-buffer)
(space-chord-define evil-normal-state-map "w" 'save-buffer)
(define-key evil-motion-state-map "H" "^")
(define-key evil-motion-state-map "L" "$")
(evil-mode 1)

(define-key evil-insert-state-map "\C-v" 'yank)

(global-linum-mode t)
(global-hl-line-mode +1)
(load-theme 'spacemacs-dark t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-buffer-menu t)

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
(global-auto-revert-mode t)

; org config
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
      ledger-binary-path "hledger"
      ledger-default-date-format "%Y-%m-%d")
(add-to-list 'auto-mode-alist '("\\.journal\\'" . ledger-mode))
(add-hook 'ledger-mode-hook
          (lambda ()
            (auto-revert-mode)
            (setq-local tab-always-indent 'complete)))

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
 '(ledger-binary-path "hledger" t)
 '(org-export-backends (quote (ascii html icalendar latex md)))
 '(package-selected-packages
   (quote
    (counsel ivy-clojuredocs ivy-posframe ivy pyvenv cobol-mode org-journal json-mode ob-go htmlize haskell-mode monokai-theme spacemacs-theme zenburn-theme rust-mode terraform-mode go-mode ansible markdown-mode ledger-mode tide evil)))
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

(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-14"))

(setq visible-bell 1)

; bats support
(add-to-list 'auto-mode-alist '("\\.bats\\'" . sh-mode))
(add-hook 'sh-mode-hook
          (lambda ()
            (when buffer-file-name
                (if (string-match "\\.bats$" buffer-file-name)
                    (sh-set-shell "bash")
                    (if (string-match "\\.sh$" buffer-file-name)
                        (sh-set-shell "bash"))))))


(setq sh-basic-offset 2)

(add-to-list 'load-path "~/.emacs.d/rust-mode")
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

; This doesn't actually do anything afaict.  TODO: figure out how to
; make org mode open Firefox instead of Chromium.
(setq browser-url-browser-function 'browse-url-firefox)

;;; org babel ;;;
(require 'ob-js)

;; Run and highlight code using babel in org-mode
;; via http://cachestocaches.com/2018/6/org-literate-programming/
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (python . t)
   (shell . t)
   (C . t)
   (org . t)
   (emacs-lisp . t)
   (go . t)
   (java . t)
   (js . t)
   (ruby . t)
   ))
;; Use python3 in babel
(setq org-babel-python-command "python3")
;; Use bash in babel
(setq org-babel-shell-command "bash")
;; Syntax highlight in #+BEGIN_SRC blocks
(setq org-src-fontify-natively t)
;; Don't prompt before running code in org
(setq org-confirm-babel-evaluate nil)

;; (setq org-html-htmlize-output-type 'inline-css) ;; default
(setq org-html-htmlize-output-type 'css)
;; (setq org-html-htmlize-font-prefix "") ;; default
(setq org-html-htmlize-font-prefix "org-")

;; override the structure template to insert lowercase delimters
;; https://orgmode.org/manual/Structure-Templates.html
;; https://emacs.stackexchange.com/a/12847
;; the '?' denotes where the cursor should be after template insertion
(add-to-list 'org-structure-template-alist
             '("s" "#+begin_src ?\n#+end_src"))
(add-to-list 'org-structure-template-alist
             '("sh" "#+begin_src sh\n?\n#+end_src" ""))


;;; org-journal ;;;

(setq org-journal-dir "~/org/journal/")
(setq org-journal-date-format "%A, %Y-%m-%d")
(require 'org-journal)

;; ivy and counsel
(ivy-mode 1)
(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)

(require 'ivy-rich)
(all-the-icons-ivy-rich-mode 1)
(ivy-rich-mode 1)
(setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
(setq ivy-rich-path-style 'abbrev)


(require 'ivy-posframe)
;; display at `ivy-posframe-style'
(setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-center)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-bottom-left)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-bottom-left)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center)))
(ivy-posframe-mode 1)
(defun posframe-poshandler-window-top-center-offset (info)
  "Posframe's position handler.

Get a position which let posframe stay onto current window's
top center.  The structure of INFO can be found in docstring of
`posframe-show'."
  (let* ((window-left (plist-get info :parent-window-left))
         (window-top (plist-get info :parent-window-top))
         (window-width (plist-get info :parent-window-width))
         (posframe-width (plist-get info :posframe-width)))
    (cons (+ window-left (/ (- window-width posframe-width) 2))
          (+ window-top 48))))
