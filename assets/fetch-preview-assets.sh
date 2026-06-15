#!/usr/bin/env bash
# 下載 markdown 預覽用的本地 JS(離線,免 CDN):mermaid(UMD 單檔) + MathJax v3(單檔)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
curl -fsSL -o mermaid.min.js     "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"
curl -fsSL -o tex-mml-chtml.js   "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
echo "✔ 已下載 mermaid.min.js + tex-mml-chtml.js 到 $(pwd)"
