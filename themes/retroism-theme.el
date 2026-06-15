;;; retroism-theme.el --- Retroism yorha theme -*- lexical-binding: t; -*-

(deftheme retroism
  "Retroism yorha theme for Emacs.")

(let ((bg "#d9caba")
      (bg-alt "#cfc0ac")
      (fg "#2b2a26")
      (fg-soft "#3e3d38")
      (muted "#8a7c66")
      (border "#8a7c66")
      (selection "#b8a98f")
      (line-nr "#a89a82")
      (accent "#626335")
      (accent-light "#f0e2d3")
      (red "#9e3b2e")
      (green "#5e6e2f")
      (yellow "#a8782a")
      (blue "#3d5a72")
      (purple "#7c4a60")
      (cyan "#3f7068"))
  (custom-theme-set-faces
   'retroism
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

   `(mode-line ((t (:foreground ,accent-light :background ,accent :box (:line-width 1 :style released-button) :weight bold))))
   `(mode-line-inactive ((t (:foreground ,muted :background ,bg-alt :box (:line-width 1 :color ,border)))))
   `(header-line ((t (:foreground ,fg-soft :background ,bg-alt :box (:line-width 2 :style released-button) :weight bold))))
   `(vertical-border ((t (:foreground ,border))))

   ;; 立體浮雕的視窗分隔線(亮邊在上/左、暗邊在下/右)
   `(window-divider ((t (:foreground ,bg-alt))))
   `(window-divider-first-pixel ((t (:foreground ,accent-light))))
   `(window-divider-last-pixel ((t (:foreground ,border))))

   ;; Platinum 立體分頁(tab-bar)
   `(tab-bar ((t (:background ,bg-alt :foreground ,fg :box (:line-width 1 :color ,border)))))
   `(tab-bar-tab ((t (:background ,bg :foreground ,fg :weight bold :box (:line-width 2 :style released-button)))))
   `(tab-bar-tab-inactive ((t (:background ,bg-alt :foreground ,muted :box (:line-width 2 :style pressed-button)))))

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
   'retroism
   `(ansi-color-names-vector
     [,fg ,red ,green ,yellow ,blue ,purple ,cyan ,fg-soft])))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-directory load-file-name)))

(provide-theme 'retroism)

;;; retroism-theme.el ends here
