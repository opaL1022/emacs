;;; init.el --- Minimal Emacs config -*- lexical-binding: t; -*-

;;; Basic UI

;; Mac OS Platinum 的招牌：永遠掛在頂端的選單列(交給 GTK Platinum 主題繪製)
(menu-bar-mode 1)
(tool-bar-mode -1)

;; Retro toolkit scroll bars — drawn by the ClassicPlatinum GTK theme
;; (chunky 3D trough + paired stepper arrows). Classic right-hand placement.
(scroll-bar-mode 1)
(set-scroll-bar-mode 'right)
(add-to-list 'default-frame-alist '(scroll-bar-width . 16))

;; 視窗之間用立體分隔線(取代細線)，更有 Platinum 的 3D 浮雕感
(window-divider-mode 1)
(setq window-divider-default-places t
      window-divider-default-right-width 3
      window-divider-default-bottom-width 3)

(global-display-line-numbers-mode 1)
(column-number-mode 1)
(size-indication-mode 1)   ; 老系統味的「行/欄 + 檔案位置%」狀態列

;;; Platinum native chrome — 讓彈出元素都走 GTK(Platinum 外觀)

(setq use-dialog-box t             ; yes/no 用 Platinum 對話框
      use-file-dialog t            ; 開檔走 GTK 檔案對話框
      x-gtk-use-system-tooltips t) ; tooltip 用系統(Platinum)樣式

(tooltip-mode 1)
(context-menu-mode 1)              ; 右鍵 = Platinum 風格 context menu

;;; Platinum 視窗標題列 — 每個 window 頂端置中 buffer 名(仿 Mac OS 8/9 視窗標題)

(defun my-platinum-title-bar ()
  "把 buffer 名置中，模擬 Mac Platinum 的視窗標題列。修改過的檔加上 ◆。"
  (let* ((title (concat " " (buffer-name)
                        (when (and buffer-file-name (buffer-modified-p)) " ◆")
                        " "))
         (avail (max 0 (- (window-total-width) (string-width title))))
         (left  (make-string (/ avail 2) ?\s)))
    (concat left title)))

;; 只在「實檔/一般」buffer 掛標題列；像 magit 等自帶 header-line 的不覆蓋
(defun my-enable-platinum-title-bar ()
  "在目前 buffer 啟用 Platinum 標題列，除非該 buffer 已自訂 header-line。"
  (unless (or header-line-format (minibufferp))
    (setq header-line-format '((:eval (my-platinum-title-bar))))))

(add-hook 'after-change-major-mode-hook #'my-enable-platinum-title-bar)

;;; Better defaults

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq ring-bell-function 'ignore)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(delete-selection-mode 1)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;;; Package setup

(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(unless (bound-and-true-p package--initialized)
  (package-initialize))

;;; use-package

(unless (package-installed-p 'use-package)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

;;; Custom file

(when (file-exists-p custom-file)
  (load custom-file))

;;; Theme

(load-theme 'retroism t)

;;; Font

(defvar my-font-family "Dank Mono")
(defvar my-font-height 180)
(defvar my-ui-font-family "Charcoal") ; Mac OS 8/9 系統 UI 字，給 variable-pitch

(defun my-set-font-for-frame (frame)
  "Set font for graphical FRAME."
  (when (display-graphic-p frame)
    (set-face-attribute 'default frame
                        :family my-font-family
                        :height my-font-height)))

(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family my-font-family
                      :height my-font-height))

(add-hook 'after-make-frame-functions #'my-set-font-for-frame)

;; UI 元素(variable-pitch：Info、which-key、各種比例字介面)用 Mac 系統字 Charcoal
(when (display-graphic-p)
  (set-face-attribute 'variable-pitch nil
                      :family my-ui-font-family
                      :height my-font-height))

;;; Completion

(use-package vertico
  :init
  (vertico-mode 1))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Git

(use-package magit
  :bind ("C-x g" . magit-status))

;;; init.el ends here
