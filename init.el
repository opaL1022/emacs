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
      ;; 0px 縫:仍是獨立字元→斷開 face run(每個按鈕各自畫浮雕邊),但寬度 0,
      ;; 相鄰按鈕的浮雕邊直接相接,純靠「暗陰影邊 + 亮高光邊」當立體分界,無任何縫
      tab-bar-separator (propertize " " 'display '(space :width (0))
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

;;; Undo — 直覺的 undo/redo + 跨重開保留歷史

(use-package undo-fu
  :bind (("C-/" . undo-fu-only-undo)    ; undo
         ("C-?" . undo-fu-only-redo)))  ; redo = Ctrl+Shift+/

;; 把 undo 歷史存到磁碟,重開檔案後可繼續 undo 到之前的變動
(use-package undo-fu-session
  :init
  (undo-fu-session-global-mode 1))

;;; Git

(use-package magit
  :bind ("C-x g" . magit-status))

;;; 括號 — 自動補對 + 高亮對應(全內建)

(electric-pair-mode 1)          ; 打 ( 自動補 )、選取後打括號會包住選取
(setq show-paren-delay 0)
(show-paren-mode 1)             ; 高亮對應括號(主題已設配色)

;;; corfu — buffer 內即時補全 popup(LSP/關鍵字候選打字就跳)

(use-package corfu
  :init
  (global-corfu-mode 1)
  :custom
  (corfu-auto t)                ; 打字自動跳候選(不用按 TAB)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)         ; 打滿 2 個字才跳
  (corfu-cycle t)               ; 候選循環
  (corfu-quit-no-match 'separator)
  :config
  (corfu-popupinfo-mode 1))     ; 候選旁顯示文件說明
(setq tab-always-indent 'complete) ; TAB:先縮排,已對齊時觸發補全

;;; 語言 major mode(內建以外的) + 副檔名映射

(use-package lua-mode)
(use-package markdown-mode
  :config
  (let* ((cfg (expand-file-name "assets/markdown_py.json" user-emacs-directory))
         ;; 數學:優先用本地 mathjax 套件(pacman 裝),沒裝才退回 CDN
         (mathjax (let ((local (seq-find #'file-exists-p
                                        '("/usr/share/mathjax/es5/tex-mml-chtml.js"
                                          "/usr/share/mathjax/tex-mml-chtml.js"
                                          "/usr/share/mathjax3/es5/tex-mml-chtml.js"))))
                    (if local (concat "file://" local)
                      "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"))))
    ;; Python-Markdown + 擴充(預設那支不渲染表格等 GFM)。需 python-pymdown-extensions。
    ;; extra=表格/圍欄程式碼/註腳；tilde=刪節線~~；tasklist=工作清單[ ]；arithmatex=數學$..$
    (setq markdown-command
          (format (concat "markdown_py -x extra -x sane_lists "
                          "-x pymdownx.tilde -x pymdownx.tasklist -x pymdownx.arithmatex -c %s")
                  (shell-quote-argument cfg)))
    ;; 瀏覽器預覽(C-c C-c v)的 <head>:CSS + MathJax(本地套件) + mermaid(CDN,不常用)，
    ;; 並把 ```mermaid(輸出成 code.language-mermaid)轉成 .mermaid div 來繪圖。
    ;; 走 JS,所以只有 C-c C-c v(外部瀏覽器)會畫 mermaid/數學;eww live 不跑 JS。
    (setq markdown-xhtml-header-content
          (concat
           "<meta charset=\"utf-8\">"
           "<style>"
           "body{max-width:880px;margin:0 auto;padding:2rem;line-height:1.6;"
           "font-family:-apple-system,'Segoe UI',Helvetica,Arial,sans-serif;color:#24292f;}"
           "table{border-collapse:collapse;}th,td{border:1px solid #d0d7de;padding:.4em .8em;}"
           "th{background:#f6f8fa;}pre{background:#f6f8fa;padding:1em;overflow:auto;border-radius:6px;}"
           "code{font-family:ui-monospace,monospace;}blockquote{color:#57606a;border-left:.25em solid #d0d7de;padding:0 1em;margin:0;}"
           "</style>"
           ;; 數學:本地 mathjax 套件(沒裝自動退回 CDN)
           "<script id=\"MathJax-script\" async src=\"" mathjax "\"></script>"
           ;; mermaid:CDN(不常用,直接連網)
           "<script type=\"module\">"
           "import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';"
           "mermaid.initialize({startOnLoad:false,theme:'neutral'});"
           "window.addEventListener('load',()=>{"
           "document.querySelectorAll('code.language-mermaid').forEach((el)=>{"
           "const d=document.createElement('div');d.className='mermaid';d.textContent=el.textContent;"
           "el.closest('pre').replaceWith(d);});mermaid.run();});"
           "</script>"))))
;; CUDA / HIP 本質是 C++,交給 c++-mode + clangd
(dolist (pat '("\\.cu\\'" "\\.cuh\\'" "\\.hip\\'"))
  (add-to-list 'auto-mode-alist (cons pat 'c++-mode)))

;;; eglot — LSP client(Emacs 30 內建)

(use-package eglot
  :ensure nil                   ; 內建,不從 elpa 裝
  :hook ((python-mode c-mode c++-mode lua-mode sh-mode
          latex-mode markdown-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)        ; 重新命名符號
              ("C-c l a" . eglot-code-actions)  ; code action
              ("C-c l f" . eglot-format))       ; 格式化
  :custom
  (eglot-autoshutdown t)        ; 最後一個 buffer 關掉就停 server
  :config
  ;; 指定各語言用哪個 server(eglot 只是 client;clangd 是 c/c++ 預設,不用設)
  (add-to-list 'eglot-server-programs '((python-mode)      . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs '((lua-mode)         . ("lua-language-server")))
  (add-to-list 'eglot-server-programs '((sh-mode)          . ("bash-language-server" "start")))
  ;; LaTeX-mode 是 AUCTeX 的 major mode(不是內建 latex-mode 衍生),要單獨列才吃 texlab
  (add-to-list 'eglot-server-programs '((LaTeX-mode latex-mode tex-mode) . ("texlab")))
  (add-to-list 'eglot-server-programs '((markdown-mode)    . ("marksman"))))

;;; LaTeX — AUCTeX + latexmk 編譯 + zathura 看 PDF(SyncTeX);texlab LSP 已在 eglot 接上

;; 套件名是 auctex,但要設定的 feature 是 tex(否則 :config 會在 TeX-command-list
;; 還沒定義時就跑而報錯)。用 :ensure auctex 裝套件、用 tex 當載入點。
(use-package tex
  :ensure auctex
  :defer t
  :hook ((LaTeX-mode . eglot-ensure)              ; texlab(補全/診斷/跳定義)
         (LaTeX-mode . TeX-source-correlate-mode) ; SyncTeX:原稿 ↔ PDF 互跳
         (LaTeX-mode . turn-on-reftex))           ; \ref \cite 導覽(reftex,內建)
  :init
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-master nil                            ; 多檔專案會問主檔
        TeX-PDF-mode t
        reftex-plug-into-AUCTeX t
        TeX-source-correlate-start-server t
        ;; 用 zathura 看 PDF(AUCTeX 內建條目,含 SyncTeX 正向跳轉)
        TeX-view-program-selection '((output-pdf "Zathura")))
  :config
  ;; latexmk 編譯(自動跑多次 pass + 參考文獻);設成 C-c C-c 的預設指令
  (add-to-list 'TeX-command-list
               '("LatexMk" "latexmk -pdf -synctex=1 -interaction=nonstopmode %t"
                 TeX-run-TeX nil (LaTeX-mode) :help "latexmk → PDF"))
  (setq-default TeX-command-default "LatexMk"))

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
