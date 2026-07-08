;;; surrealism-theme.el --- Magritte night theme -*- lexical-binding: t; -*-

;; surrealism「空 / The Empty Sky」的 Emacs 版:Magritte 夜色。
;; 配色沿用桌面主題(夜空深藍底 + 雲白字 + 街燈金強調);
;; 反轉 retroism 的 Platinum 立體浮雕 → 扁平(near-frameless 的物件感)。

(deftheme surrealism
  "Magritte night theme for Emacs (surrealism / The Empty Sky).")

(let ((bg "#141c28")          ; night 深藍底
      (bg-alt "#1d2739")      ; 稍亮(hl-line / inactive mode-line)
      (fg "#e6ecf3")          ; cloud 雲白
      (fg-soft "#c4cdd8")     ; 雲灰
      (muted "#8290a8")       ; 註解 dim blue-grey
      (border "#3a4a63")
      (selection "#33506a")   ; sky-dusk 選取
      (line-nr "#57617a")
      (accent "#e6b24e")      ; lamp 街燈金(唯一暖色:mode-line 底 / 游標 / 強調)
      (accent-light "#141c28"); 金條上的深色字
      (red "#d47b6d")
      (green "#9fd487")
      (yellow "#eab74f")
      (blue "#8fc8f2")        ; sky
      (purple "#ad8cc4")      ; dusk
      (cyan "#82bfcd"))
  (custom-theme-set-faces
   'surrealism
   `(default ((t (:foreground ,fg :background ,bg))))
   `(cursor ((t (:background ,accent))))
   `(fringe ((t (:foreground ,muted :background ,bg))))
   `(scroll-bar ((t (:foreground ,accent :background ,bg-alt))))
   `(region ((t (:background ,selection))))
   `(highlight ((t (:background ,bg-alt))))
   `(hl-line ((t (:background ,bg-alt))))
   `(shadow ((t (:foreground ,muted))))
   `(minibuffer-prompt ((t (:foreground ,accent :weight bold))))
   `(link ((t (:foreground ,blue :underline t))))
   `(error ((t (:foreground ,red :weight bold))))
   `(warning ((t (:foreground ,yellow :weight bold))))
   `(success ((t (:foreground ,green :weight bold))))

   ;; 扁平 mode-line(無 Platinum 浮雕):街燈金底 + 夜色字
   `(mode-line ((t (:foreground ,accent-light :background ,accent :box (:line-width 3 :color ,accent) :weight bold))))
   `(mode-line-inactive ((t (:foreground ,muted :background ,bg-alt :box (:line-width 3 :color ,bg-alt)))))
   `(header-line ((t (:foreground ,fg :background ,bg-alt :box (:line-width 3 :color ,bg-alt)))))
   `(vertical-border ((t (:foreground ,border))))

   ;; 扁平視窗分隔線(無立體浮雕)
   `(window-divider ((t (:foreground ,border))))
   `(window-divider-first-pixel ((t (:foreground ,border))))
   `(window-divider-last-pixel ((t (:foreground ,border))))

   ;; 扁平分頁(tab-bar):金底作用分頁 + 夜色字,不用立體按鈕
   `(tab-bar ((t (:background ,bg-alt :foreground ,fg))))
   `(tab-bar-tab ((t (:background ,accent :foreground ,accent-light :weight bold :box (:line-width 3 :color ,accent)))))
   `(tab-bar-tab-inactive ((t (:background ,bg-alt :foreground ,muted :box (:line-width 3 :color ,bg-alt)))))

   `(line-number ((t (:foreground ,line-nr :background ,bg))))
   `(line-number-current-line ((t (:foreground ,accent :background ,bg-alt :weight bold))))

   `(font-lock-comment-face ((t (:foreground ,muted :slant italic))))
   `(font-lock-doc-face ((t (:foreground ,muted :slant italic))))
   `(font-lock-string-face ((t (:foreground ,green))))
   `(font-lock-constant-face ((t (:foreground ,yellow))))
   `(font-lock-builtin-face ((t (:foreground ,accent :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,blue))))
   `(font-lock-keyword-face ((t (:foreground ,purple :weight bold))))
   `(font-lock-type-face ((t (:foreground ,cyan :weight bold))))
   `(font-lock-variable-name-face ((t (:foreground ,fg-soft))))
   `(font-lock-warning-face ((t (:foreground ,red :weight bold))))

   `(isearch ((t (:foreground ,accent-light :background ,accent :weight bold))))
   `(lazy-highlight ((t (:foreground ,fg :background ,selection))))
   `(match ((t (:foreground ,accent-light :background ,accent :weight bold))))

   `(completions-common-part ((t (:foreground ,accent :weight bold))))
   `(completions-first-difference ((t (:foreground ,red :weight bold))))
   `(vertico-current ((t (:background ,selection :weight bold))))
   `(marginalia-documentation ((t (:foreground ,muted :slant italic))))
   `(marginalia-key ((t (:foreground ,accent))))

   ;; corfu buffer 內補全 popup
   `(corfu-default ((t (:background ,bg-alt :foreground ,fg))))
   `(corfu-current ((t (:background ,selection :foreground ,fg :weight bold))))
   `(corfu-border ((t (:background ,border))))
   `(corfu-bar ((t (:background ,accent))))

   `(show-paren-match ((t (:foreground ,accent-light :background ,accent :weight bold))))
   `(show-paren-mismatch ((t (:foreground ,accent-light :background ,red :weight bold))))

   `(diff-added ((t (:foreground ,green :background ,bg))))
   `(diff-removed ((t (:foreground ,red :background ,bg))))
   `(diff-changed ((t (:foreground ,yellow :background ,bg))))
   `(diff-header ((t (:foreground ,accent :background ,bg-alt :weight bold))))
   `(diff-file-header ((t (:foreground ,accent-light :background ,accent :weight bold))))

   `(magit-section-heading ((t (:foreground ,accent :weight bold))))
   `(magit-branch-local ((t (:foreground ,blue))))
   `(magit-branch-remote ((t (:foreground ,green))))
   `(magit-diff-added ((t (:foreground ,green :background ,bg))))
   `(magit-diff-removed ((t (:foreground ,red :background ,bg))))
   `(magit-diff-context ((t (:foreground ,fg-soft :background ,bg))))
   `(magit-diff-hunk-heading ((t (:foreground ,fg :background ,bg-alt))))
   `(magit-diff-hunk-heading-highlight ((t (:foreground ,accent-light :background ,accent))))
   `(magit-diff-file-heading ((t (:foreground ,accent :weight bold))))

   `(whitespace-space ((t (:foreground ,line-nr))))
   `(whitespace-tab ((t (:foreground ,line-nr))))
   `(trailing-whitespace ((t (:background ,red)))))

  (custom-theme-set-variables
   'surrealism
   `(ansi-color-names-vector
     [,fg ,red ,green ,yellow ,blue ,purple ,cyan ,fg-soft])))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-directory load-file-name)))

(provide-theme 'surrealism)

;;; surrealism-theme.el ends here
