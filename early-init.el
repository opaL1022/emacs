;;; early-init.el --- Early startup config -*- lexical-binding: t; -*-

;;; Package startup

(setq package-enable-at-startup nil)

;;; Classic always-visible GTK scroll bars (no auto-hide overlay)

(setenv "GTK_OVERLAY_SCROLLING" "0")

;;; Startup UI

(setq inhibit-startup-screen t)

(setq native-comp-async-report-warnings-errors 'silent)

(setq frame-inhibit-implied-resize t)

(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))

;;; Initial font

(add-to-list 'default-frame-alist '(font . "Monaco-16"))

;;; early-init.el ends here
