;;; init.el --- Minimal Emacs config -*- lexical-binding: t; -*-

;;; Basic UI

;; ── Emacs 外觀跟著 dotfiles 當前主題分支走 ──
;; 切桌面主題後,重啟 emacs / daemon 即同步:
;;   surrealism → Magritte 夜色極簡(無 menu-bar / 無捲軸 / 扁平分隔線)
;;   retroism   → Mac Platinum(menu-bar + 立體捲軸 + 3D 分隔線)
(defvar my-desktop-theme
  (let ((b (string-trim
            (shell-command-to-string
             "git -C ~/dotfiles symbolic-ref --short HEAD 2>/dev/null"))))
    (if (member b '("retroism" "surrealism")) b "surrealism"))
  "當前桌面主題(讀 dotfiles git 分支;認不得就當 surrealism)。")
(defvar my-retro-p (string= my-desktop-theme "retroism"))

;; menu-bar:retroism 掛頂端選單列(Platinum 招牌);surrealism 極簡拿掉
(menu-bar-mode (if my-retro-p 1 -1))
(tool-bar-mode -1)

;; 捲軸:retroism 走 ClassicPlatinum 粗捲軸(3D trough + 右側);surrealism 無捲軸
(if my-retro-p
    (progn
      (scroll-bar-mode 1)
      (set-scroll-bar-mode 'right)
      (add-to-list 'default-frame-alist '(scroll-bar-width . 16)))
  (scroll-bar-mode -1))

;; surrealism 專屬留白:內容離視窗邊緣浮開 + 字距更透氣
;; → 呼應桌面「大量留白 / 浮在空中的物件」;retroism 維持緊湊 Platinum 面板感
(unless my-retro-p
  (add-to-list 'default-frame-alist '(internal-border-width . 18))
  ;; 背景微透 → 透出夜空(Emacs 29+ alpha-background:只透背景、文字不透,可讀)
  (add-to-list 'default-frame-alist '(alpha-background . 92))
  (setq-default line-spacing 3))

;; 視窗之間用立體分隔線(取代細線)，更有 Platinum 的 3D 浮雕感
(window-divider-mode 1)
(setq window-divider-default-places t
      window-divider-default-right-width (if my-retro-p 3 1)   ; retroism 3D 浮雕 / surrealism 扁平
      window-divider-default-bottom-width (if my-retro-p 3 1))

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

(load-theme (if my-retro-p 'retroism 'surrealism) t)

;; surrealism:失焦視窗淡出(呼應桌面「聚焦=在場、失焦=溶回天空」《人的境況》)
(unless my-retro-p
  (use-package dimmer
    :config
    (setq dimmer-fraction 0.35)
    (dimmer-configure-which-key)
    (dimmer-configure-magit)
    (dimmer-mode 1)))

;; 熱套用:重讀 dotfiles 分支,把整套外觀套到「現有」frame(不重啟 daemon、不丟 buffer)。
;; theme-switch 切桌面主題後會 emacsclient 呼叫這個 → Emacs 即時跟著變 retroism/surrealism。
(defun my-apply-desktop-look ()
  "重讀 dotfiles 當前主題分支,套用對應 Emacs 外觀(主題/chrome/留白/透明/失焦淡出)。"
  (interactive)
  (setq my-desktop-theme
        (let ((b (string-trim (shell-command-to-string
                   "git -C ~/dotfiles symbolic-ref --short HEAD 2>/dev/null"))))
          (if (member b '("retroism" "surrealism")) b "surrealism"))
        my-retro-p (string= my-desktop-theme "retroism"))
  ;; 主題
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme (if my-retro-p 'retroism 'surrealism) t)
  ;; chrome
  (menu-bar-mode (if my-retro-p 1 -1))
  (if my-retro-p (progn (scroll-bar-mode 1) (set-scroll-bar-mode 'right)) (scroll-bar-mode -1))
  (setq window-divider-default-right-width (if my-retro-p 3 1)
        window-divider-default-bottom-width (if my-retro-p 3 1))
  (window-divider-mode 1)
  ;; 留白 / 背景透明:default-frame-alist(新 frame)+ 套到既有 frame
  (let ((ib (if my-retro-p 0 18)) (ab (if my-retro-p 100 92)))
    (setf (alist-get 'internal-border-width default-frame-alist) ib
          (alist-get 'alpha-background default-frame-alist) ab)
    (setq-default line-spacing (if my-retro-p nil 3))
    (dolist (f (frame-list))
      (set-frame-parameter f 'internal-border-width ib)
      (set-frame-parameter f 'alpha-background ab)))
  ;; 失焦淡出:surrealism 開、retroism 關
  (when (require 'dimmer nil t)
    (dimmer-mode (if my-retro-p -1 1))))

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
  (completion-category-overrides
   '((file (styles basic partial-completion))
     (eglot (styles basic))           ; LSP 候選照 clangd 自己的排序/前綴過濾,不被 orderless 打亂
     (eglot-capf (styles basic)))))

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

;;; sudo 編輯 — 用 TRAMP 的 /sudo:: 以 root 開檔(內建,免裝)

;; 直接開:本機 C-x C-f /sudo::/etc/fstab;遠端 /ssh:host|sudo:host:/etc/fstab
;; 已開的檔發現沒權限存 → M-x my-sudo-edit 用 root 原地重開(本機/遠端皆可)
(defun my-sudo-edit (&optional file)
  "用 root 重新開啟 FILE(預設為目前 buffer 的檔)。
本機檔走 /sudo::;遠端 TRAMP 檔則在「同一台主機」上再跳一手 sudo。"
  (interactive)
  (require 'tramp)
  (let ((target (or file buffer-file-name
                    (read-file-name "以 root 開啟檔案: "))))
    (find-file
     (if (tramp-tramp-file-p target)
         ;; 遠端:/<method>:<user@>host|sudo:host:<localname>
         (let* ((v (tramp-dissect-file-name target))
                (method (tramp-file-name-method v))
                (user   (tramp-file-name-user v))
                (host   (tramp-file-name-host v)))
           (format "/%s:%s%s|sudo:%s:%s"
                   method (if user (concat user "@") "") host
                   host (tramp-file-name-localname v)))
       (concat "/sudo::" (expand-file-name target))))))
(global-set-key (kbd "C-c f s") #'my-sudo-edit)

;;; TRAMP 連線共用 — 讓 TRAMP 改吃 ~/.ssh/config 的 ControlMaster
;; 預設 tramp-use-connection-share=t 時,TRAMP 會在命令列自己塞
;; -o ControlPath=<自己的> -o ControlPersist=no,覆蓋掉 ssh config,
;; 導致主連線與 eglot 遠端 server(bash-language-server/pyright/clangd…)
;; 各開一條沒共用 master 的 ssh → 每次都要重新 OTP。設 nil 後全部多工
;; 共用 ~/.ssh/%r@%h:%p 這個 master(先 `ssh -MNf f1` 認證一次即可)。
(with-eval-after-load 'tramp
  (setq tramp-use-connection-share nil))

;; eglot 起遠端 LSP server 時(eglot.el, bug#61350)會用 let 把
;; tramp-use-connection-share 強制綁成 'suppress、硬加
;; -o ControlMaster=no -o ControlPath=none,給 server 開一條「不共用」的獨立
;; ssh。對國網這種 OTP 主機,這條獨立連線每次都要重新認證 → 每開一個會觸發
;; eglot 的檔(.sh/.py/.c…)就跳一次 OTP。上面的 nil 對它無效(被 let 蓋掉)。
;;
;; 這裡攔截 TRAMP 計算 ssh 選項的函式,只對這幾台 OTP 主機回傳 ""(不加任何
;; -o),讓 ~/.ssh/config 的 ControlMaster auto 接手、共用已認證的 master →
;; 全程只需一次 OTP。其他主機維持 eglot 預設(獨立連線,保留 bug#61350 防護)。
;;
;; 取捨:對這幾台等於解除 bug#61350 的保護 —— LSP 大量資料(大檔的補全/診斷)
;; 改走多工 channel,理論上可能出問題。若哪天遇到 eglot 卡住/回應被截斷,再把
;; 對應語言排除即可。清單只比對短別名;若用完整 hostname 連(/ssh:u..@f1-il..:)
;; 會漏接、OTP 會回來,固定用 f1/nano4/nano5/twcc 即可。
(with-eval-after-load 'tramp-sh
  (advice-add
   'tramp-ssh-or-plink-options :around
   (lambda (orig vec)
     (if (member (tramp-file-name-host vec) '("f1" "nano4" "nano5" "twcc"))
         ""
       (funcall orig vec)))
   '((name . my-otp-force-controlmaster))))

;;; 括號 — 自動補對 + 高亮對應(全內建)

(electric-pair-mode 1)          ; 打 ( 自動補 )、選取後打括號會包住選取
(setq show-paren-delay 0)
(show-paren-mode 1)             ; 高亮對應括號(主題已設配色)

;;; multiple-cursors — 多游標同時編輯(像 VS Code 的 Ctrl-D / 多行游標)

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)          ; 選取多行 → 每行行尾各放一個游標
         ("C->"         . mc/mark-next-like-this)  ; 標記下一個同字串,加游標(像 Ctrl-D)
         ("C-<"         . mc/mark-previous-like-this) ; 往上一個
         ("C-c C-<"     . mc/mark-all-like-this)   ; 一次標記全部同字串
         ;; 取消/微調游標:
         ("C-M->"       . mc/skip-to-next-like-this)     ; 這個不放游標,跳到下一個符合處
         ("C-M-<"       . mc/skip-to-previous-like-this) ; 往上跳過
         ("C-c C->"     . mc/unmark-next-like-this)       ; 退掉往下方向最後加的游標
         ("C-c C-,"     . mc/unmark-previous-like-this))) ; 退掉往上方向最後加的游標

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

;;; indent-rigidly(C-x TAB)— 用 < / > 推縮排,一次一個縮排層級(tab-width,非單格空格)
;; indent-rigidly-map 是預載 indent.el 裡的變數(無 provide,故不能用 with-eval-after-load),開機即存在
(define-key indent-rigidly-map (kbd ">") #'indent-rigidly-right-to-tab-stop)
(define-key indent-rigidly-map (kbd "<") #'indent-rigidly-left-to-tab-stop)

;;; yasnippet — snippet 展開引擎。eglot 靠它展開 LSP 候選裡的佔位符:
;;; 沒它的話,選函數補全只會插入函數名(沒有 () 跟參數),#include 也補不出 <>。
(use-package yasnippet
  :init
  (yas-global-mode 1))

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
  ;; latexmk 整合:引擎(pdflatex/xelatex/lualatex)跟著 AUCTeX 的 TeX-engine 走
  ;; (在引擎提示選 XeTeX/LuaTeX 就會用對的引擎),並自動帶 SyncTeX。設成 C-c C-c 預設。
  (require 'auctex-latexmk)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t)
  (auctex-latexmk-setup)
  (setq-default TeX-command-default "LatexMk"
                TeX-engine 'xetex))  ; 跟 nvim vimtex 一致:全部用 xelatex(也不再被問引擎)

;; cdlatex — 快速數學輸入(^/_ 自動補括號、`縮寫+TAB 模板、`希臘字母、'修飾、$自動成對)
(use-package cdlatex
  :hook (LaTeX-mode . turn-on-cdlatex))

;;; Startup screen — retro 風 *scratch* banner(開 Emacs 像開老應用程式)

(setq initial-major-mode 'lisp-interaction-mode)
;; banner 跟著主題:retroism = yorha·platinum;surrealism = 夜色·空,漂浮月亮 + Magritte 錯視玩笑
(setq initial-scratch-message
      (if my-retro-p "\
;;
;;   ────────────────────────────────────────────
;;     RETROISM · Emacs        yorha · platinum
;;   ────────────────────────────────────────────
;;
;;     C-x C-f   find file       C-x b   switch buffer
;;     C-x C-r   recent file     C-x g   magit
;;     M-x       run command     C-h k   describe key
;;
" "\
;;
;;                      ○
;;   ────────────────────────────────────────────
;;     SURREALISM · Emacs       空 · The Empty Sky
;;   ────────────────────────────────────────────
;;
;;     C-x C-f   find file       C-x b   switch buffer
;;     C-x C-r   recent file     C-x g   magit
;;     M-x       run command     C-h k   describe key
;;
;;     « Ceci n'est pas un éditeur »
;;
"))

;;; init.el ends here
