# 伺服器用 Emacs 設定

由 `~/.config/emacs/init.el` 精簡而來；只用 Emacs 內建功能，不下載套件、不啟動 LSP、不需要字型或 GUI。相容目標為 Emacs 26.1+；實際驗證版本為本機 Emacs 31.1，舊版尚未實機驗證。

## 直接從 GitHub 取得

在伺服器執行：

```sh
git clone --depth 1 https://github.com/opaL1022/emacs.git ~/emacs-config
emacs -Q -nw -l ~/emacs-config/server/emacs.d/init.el 要編輯的檔案
```

若 repo 為私人，需要 GitHub 存取權限，也可改用 SSH clone URL `git@github.com:opaL1022/emacs.git`。

可加入 `~/.bashrc` 或 `~/.zshrc`：

```sh
alias e='emacs -Q -nw -l ~/emacs-config/server/emacs.d/init.el'
```

更新設定使用 `git -C ~/emacs-config pull --ff-only`。執行時產生的 `var/` 和個人 `custom.el` 已排除版本控制。

## 搬到伺服器（可選：獨立目錄）

本機執行，將 `user@server` 換成實際帳號與主機：

```sh
scp -r ~/emacs-server/emacs.d user@server:~/emacs-lite.d
```

伺服器上直接啟動：

```sh
emacs -Q -nw -l ~/emacs-lite.d/init.el 要編輯的檔案
```

這個方式不會載入伺服器原本的個人設定，也不會啟用既有第三方套件。`-Q` 不會自動讀設定，所以務必保留 `-l`。設定會把歷史檔等存到自身目錄。

可加入伺服器的 `~/.bashrc` 或 `~/.zshrc`：

```sh
alias e='emacs -Q -nw -l ~/emacs-lite.d/init.el'
```

之後使用 `e foo.cpp`。不需要管理員權限；伺服器只需已有 Emacs。

## 作為預設 ~/.emacs.d

把提供的設定放成伺服器的 `~/.emacs.d` 即會自動載入，不需 alias 或 `-l`。已有設定請先備份；舊的 `~/.emacs` 或 `~/.emacs.el` 可能會優先被讀取。

```sh
git -C ~/emacs-config pull --ff-only
mkdir -p ~/.emacs.d
cp ~/emacs-config/server/emacs.d/*.el ~/.emacs.d/
emacs -nw 檔名
```

使用複製安裝時，每次更新 repo 後也要重新執行 `cp`。

壓縮包 `emacs-server.tar.gz` 包含 `emacs.d/` 和這份說明，可用 `tar -xzf emacs-server.tar.gz` 解壓。

## 保留與調整

- 配色使用內建 Wombat：深灰底、暖白字、柔和語法色，搭配低亮度行高亮與清楚的搜尋、選取色；適合 256 色終端，不需額外主題套件。
- 保留兩格 C/C++ K&R 縮排、空白取代 Tab、括號配對、括號間 Enter 展開縮排。
- 保留左右方向鍵與 `C-b` / `C-f` 不跨實體行、最近檔案、游標位置、輸入歷史。
- 相對行號只開在程式與文字 buffer，`M-x display-line-numbers-mode` 可切換。
- 補全改為 Icomplete，使用 TAB 補全、RET 確認；新版支援垂直候選列表。
- 搜尋用 Occur / project.el / rgrep；不用 rg、fd、fzf。目錄搜尋需要系統已有 grep/find，Git 專案功能需要 git，基本編輯不需要它們。
- Git 改用 VC，shell 改用 Eshell；省略 Magit、Eat、第三方語言模式、LSP、多游標、snippet、桌面主題。
- `C-/` 使用內建 `undo-only`，避免一般 undo 在操作中轉成 redo。Undo 使用內建功能，不保留跨重開 undo 歷史。Emacs 28+ 提供獨立 redo，舊版用內建 undo 操作。
- `C-?` 綁定 redo（Emacs 28+）。若按下去刪字，用 `C-h k` 再按該鍵確認是否收到 `DEL`；某些終端會把 Ctrl+Shift+/ 與 Backspace 傳成同一個字元，必須由終端按鍵編碼修正，不能直接把 DEL 改綁 redo，否則 Backspace 也會受影響。另提供 `C-c u` / `C-c r` 作為替代。Meta 鍵不通時可先按 Esc 再按對應字元。
- 與桌面版不同，開啟備份與自動儲存供 SSH 斷線復原；檔案集中在設定目錄的 `var/`，使用 `M-x recover-file` 復原。此目錄也包含最近路徑和歷史，不要一起分享。日後搬移設定只複製兩個 `.el` 檔即可。

## 常用按鍵

| 按鍵 | 功能 |
|---|---|
| `C-x C-f` / `C-x C-s` / `C-x C-c` | 開檔 / 儲存 / 離開 |
| `C-x b` / `C-x C-r` | 切換 buffer / 最近檔案 |
| `C-s` / `M-%` | 搜尋 / 互動取代 |
| `C-c p l` | 列出目前檔案的匹配行 |
| `C-c p f` / `C-c p g` | 專案找檔 / 專案搜尋（非專案則普通開檔 / rgrep） |
| `M-/` / `C-M-i` | buffer 文字補全 / major mode 補全 |
| `C-c u` / `C-c r` | undo / redo（redo 需 Emacs 28+） |
| `C-x d` / `C-x g` | Dired 檔案管理 / VC 狀態 |
| `C-c t` | Eshell |
| `C-x 2` / `C-x 3` / `C-x o` / `C-x 1` | 上下分割 / 左右分割 / 切窗 / 單窗 |
| `C-g` / `C-h k` | 取消 / 查按鍵說明 |
