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

;; 相對行號(目前行顯示絕對行號，其餘顯示與游標的距離 → 方便 nM/nk 跳行)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(size-indication-mode 1)   ; 老系統味的「行/欄 + 檔案位置%」狀態列
(global-hl-line-mode 1)    ; 高亮游標所在行(主題的 bg-alt 淡色)

;;; Platinum native chrome — 讓彈出元素都走 GTK(Platinum 外觀)

(setq use-dialog-box t             ; yes/no 用 Platinum 對話框
      use-file-dialog t            ; 開檔走 GTK 檔案對話框
      x-gtk-use-system-tooltips t) ; tooltip 用系統(Platinum)樣式

(tooltip-mode 1)
(context-menu-mode 1)              ; 右鍵 = Platinum 風格 context menu
;; 視窗標題列交給 hyprbars(外層裝飾)，Emacs 內不另放 header-line 標題

;;; Better defaults

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq ring-bell-function 'ignore)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(delete-selection-mode 1)

;;; Persistence — 記住歷史 / 最近檔案 / 游標位置(全內建)

(savehist-mode 1)                   ; minibuffer 歷史跨重開保留
(recentf-mode 1)                    ; 記錄最近開過的檔案
(setq recentf-max-saved-items 100)
(save-place-mode 1)                 ; 重開檔案時回到上次游標位置

;;; which-key — 按前綴鍵後浮出可用按鍵表(Emacs 30 內建)

(setq which-key-idle-delay 0.5)
(which-key-mode 1)

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

;;; tab-bar — Platinum 立體分頁(workspace 式；凸起/凹陷 face 已在主題設好)

(setq tab-bar-show 1                  ; 只有 ≥2 個 tab 才顯示分頁列(平時不佔空間)
      tab-bar-new-button-show nil     ; 藏掉現代風的 [+]
      tab-bar-close-button-show nil   ; 藏掉現代風的 [x]
      ;; 2px 的「亮」縫:斷開 face run(讓每個按鈕各自有浮雕邊→立體分界),
      ;; 用按鈕色而非凹槽深色,所以不會像凹陷間隔。用 display 控成 2px 寬(不是一整格)
      tab-bar-separator (propertize " " 'display '(space :width (2))
                                    'face '(:background "#d9caba"))
      tab-bar-tab-hints t)            ; 標籤前加數字 1 2 3(老介面感 + C-x t <n> 可跳)

;; 每個分頁內側留白,數字/文字不貼著浮雕邊(像有 padding 的白金按鈕)
(setq tab-bar-tab-name-format-function
      (lambda (tab i)
        (propertize
         (concat (if tab-bar-tab-hints (format "  %d  " i) "  ")
                 (alist-get 'name tab) "  ")
         'face (if (eq (car tab) 'current-tab) 'tab-bar-tab 'tab-bar-tab-inactive))))

(tab-bar-mode 1)

;;; Completion

(use-package vertico
  :init
  (vertico-mode 1))

(use-package marginalia
  :init
  (marginalia-mode 1))

;; 補全項目前面加 Nerd Font 圖示(檔案/buffer/指令…)
(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; 補全清單改成畫面正中的浮動框(像 Mac 對話框)；僅 GUI 有效,終端機自動 fallback
(use-package vertico-posframe
  :after vertico
  :custom
  (vertico-posframe-poshandler #'posframe-poshandler-frame-center) ; 出現在正中
  (vertico-posframe-border-width 2)                                ; 2px 邊框
  (vertico-posframe-width 110)
  (vertico-posframe-parameters '((left-fringe . 8) (right-fringe . 8))) ; 內距,不貼邊
  :config
  (vertico-posframe-mode 1)
  (set-face-attribute 'vertico-posframe-border nil :background "#8a7c66")) ; yorha 框色

;;; Git

(use-package magit
  :bind ("C-x g" . magit-status))

;;; Startup screen — retro 風 *scratch* banner(開 Emacs 像開老應用程式)

(setq initial-major-mode 'lisp-interaction-mode)
;; 只用上下橫線(單行,不需逐行對齊右邊),全英文
(setq initial-scratch-message "\
;;
;;   ────────────────────────────────────────────
;;     RETROISM · Emacs        yorha · platinum
;;   ────────────────────────────────────────────
;;
;;     C-x C-f   find file       C-x b   switch buffer
;;     C-x C-r   recent file     C-x g   magit
;;     M-x       run command     C-h k   describe key
;;
")

;;; init.el ends here
