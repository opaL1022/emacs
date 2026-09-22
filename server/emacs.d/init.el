;;; init.el --- Portable terminal Emacs -*- lexical-binding: t; -*-
;; Target: Emacs 26.1+, built-in libraries only. No downloads.

;; Also support: emacs -Q -nw -l /path/to/emacs.d/init.el
(setq user-emacs-directory
      (file-name-as-directory (file-name-directory
                              (or load-file-name buffer-file-name))))
(setq package-enable-at-startup nil
      inhibit-startup-screen t
      use-dialog-box nil
      use-file-dialog nil
      ring-bell-function 'ignore
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(menu-bar-mode -1)
(dolist (mode '(tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;; Match desktop editing preferences.
(setq-default indent-tabs-mode nil tab-width 2 c-basic-offset 2)
(setq c-default-style '((java-mode . "java") (awk-mode . "awk")
                        (other . "k&r")))
(column-number-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(setq display-line-numbers-type 'relative)
(when (fboundp 'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode))
(add-hook 'prog-mode-hook #'hl-line-mode)

(defun my-backward-char-within-line (&optional n)
  "Move backward by N characters without crossing the beginning of this line."
  (interactive "^p")
  (let ((n (or n 1)))
    (if (>= n 0)
        (backward-char (min n (- (point) (line-beginning-position))))
      (forward-char (min (- n) (- (line-end-position) (point)))))))

(defun my-forward-char-within-line (&optional n)
  "Move forward by N characters without crossing the end of this line."
  (interactive "^p")
  (let ((n (or n 1)))
    (if (>= n 0)
        (forward-char (min n (- (line-end-position) (point))))
      (backward-char (min (- n) (- (point) (line-beginning-position)))))))

(global-set-key (kbd "<left>") #'my-backward-char-within-line)
(global-set-key (kbd "C-b")    #'my-backward-char-within-line)
(global-set-key (kbd "<right>") #'my-forward-char-within-line)
(global-set-key (kbd "C-f")     #'my-forward-char-within-line)

(defun my-prog-newline-and-indent ()
  "Insert a properly indented newline, expanding adjacent delimiter pairs."
  (interactive)
  ;; The pair-expansion branch below bypasses `newline-and-indent', so it
  ;; must also reindent the source line (e.g. a pasted or moved if header).
  (save-excursion (indent-according-to-mode))
  (let* ((opening (char-before))
         (closing (and opening (matching-paren opening)))
         (between-pair (and closing (eq closing (char-after)))))
    (if between-pair
        ;; Create both lines before indenting: while the closing delimiter is
        ;; still on the current line, CC Mode treats it as a closing line and
        ;; will not apply the body indentation.
        (let ((electric-pair-open-newline-between-pairs nil))
          (newline 2)
          (indent-according-to-mode)
          (forward-line -1)
          (indent-according-to-mode))
      (newline-and-indent))))

(define-key prog-mode-map (kbd "RET") #'my-prog-newline-and-indent)
(define-key prog-mode-map (kbd "<return>") #'my-prog-newline-and-indent)
(setq show-paren-delay 0)
(show-paren-mode 1)             ; 高亮對應括號(主題已設配色)


;; Store history and recovery files together, away from edited directories.
(defconst my-state-directory (expand-file-name "var/" user-emacs-directory))
(let ((default-file-modes #o700))
  (make-directory my-state-directory t)
  (make-directory (expand-file-name "backups/" my-state-directory) t)
  (make-directory (expand-file-name "auto-save/" my-state-directory) t))
(setq savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      recentf-max-saved-items 100
      recentf-auto-cleanup 'never
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" my-state-directory)))
      backup-by-copying t
      version-control t
      kept-new-versions 3 kept-old-versions 1 delete-old-versions t
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my-state-directory) t))
      auto-save-list-file-prefix
      (expand-file-name "auto-save/.saves-" my-state-directory))
(savehist-mode 1)
(save-place-mode 1)
(require 'recentf)
(recentf-mode 1)

;; Icomplete supplies minibuffer candidates; TAB completes, RET confirms.
(require 'icomplete)
(icomplete-mode 1)
(when (fboundp 'icomplete-vertical-mode) (icomplete-vertical-mode 1))
(setq completion-styles '(basic partial-completion flex))
(unless (assq 'flex completion-styles-alist)
  (setq completion-styles '(basic partial-completion)))
(when (require 'which-key nil t)
  (setq which-key-idle-delay 0.5)
  (which-key-mode 1))

(defun my-recent-file ()
  "Open a recently visited file with completion."
  (interactive)
  (find-file (completing-read "Recent file: " recentf-list nil t)))

;; Newer project.el uses existing Git/find; older Emacs falls back to Dired.
(defun my-project-find-file ()
  "Find a project file, or open a file normally outside a project."
  (interactive)
  (if (and (require 'project nil t)
           (fboundp 'project-find-file) (project-current nil))
      (call-interactively #'project-find-file)
    (call-interactively #'find-file)))

(defun my-project-grep ()
  "Search a project with built-in xref, or use rgrep in a chosen directory."
  (interactive)
  (if (and (require 'project nil t)
           (fboundp 'project-find-regexp) (project-current nil))
      (call-interactively #'project-find-regexp)
    (call-interactively #'rgrep)))

(global-set-key (kbd "C-x C-r") #'my-recent-file)
(global-set-key (kbd "C-c p f") #'my-project-find-file)
(global-set-key (kbd "C-c p g") #'my-project-grep)
(global-set-key (kbd "C-c p l") #'occur)
(global-set-key (kbd "C-c t") #'eshell)
(global-set-key (kbd "C-x g") #'vc-dir)
(global-set-key (kbd "C-c u") #'undo)
(global-set-key (kbd "C-/") #'undo)
(when (fboundp 'undo-redo)
  (global-set-key (kbd "C-?") #'undo-redo)
  (global-set-key (kbd "C-c r") #'undo-redo))
(dolist (pat '("\\.cu\\'" "\\.cuh\\'" "\\.hip\\'"))
  (add-to-list 'auto-mode-alist (cons pat 'c++-mode)))
(setq initial-scratch-message
      ";; Terminal Emacs — built-in tools only.
;; C-x C-f: open  C-x C-s: save  C-x C-c: exit
;; C-c p l: search lines  C-c t: eshell  C-h k: key help

")
(when (file-readable-p custom-file) (load custom-file nil t))
;;; init.el ends here
