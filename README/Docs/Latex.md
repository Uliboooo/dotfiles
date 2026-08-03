# LaTeX (LuaLaTeX) 日本語文書作成ガイド

## 2. 推奨ドキュメントクラス

| クラス | 用途 |
|---|---|
| `ltjsarticle` | 一般的な日本語論文・レポート（推奨） |
| `ltjsbook` | 書籍・長文 |
| `jlreq` | JIS X 4051 準拠の組版 |

## 3. 最小構成テンプレート

```latex
\documentclass[a4paper,12pt]{ltjsarticle}

% フォント設定（原ノ味フォント：外部フォント不要）
\usepackage[haranoaji]{luatexja-preset}

% 基本パッケージ
\usepackage{amsmath}
\usepackage{hyperref}

\title{タイトル}
\author{著者名}
\date{\today}

\begin{document}
\maketitle

\section{はじめに}
本文をここに記述します。

\end{document}
```

## 4. コンパイル方法

### 4.1 手動コンパイル

```bash
lualatex document.tex
```

### 4.2 latexmk (推奨)

プロジェクトルートに `.latexmkrc` を配置すると便利です：

```perl
$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error %O %S';
$pdf_mode = 4;   # 4 = lualatex
```

実行コマンド：
```bash
latexmk document.tex          # コンパイル
latexmk -pvc document.tex     # ファイル監視モード
latexmk -C document.tex       # 中間ファイルとPDFの削除
```

## 6. フォント設定パターン

### 6.1 原ノ味プリセット（最推奨：外部フォント不要）
```latex
\usepackage[haranoaji]{luatexja-preset}
```

### 6.2 Noto CJK（システムインストール済みの場合）
```latex
\usepackage{luatexja-fontspec}
\setmainjfont{Noto Serif CJK JP}
\setsansjfont{Noto Sans CJK JP}
```

## 7. よくあるエラーと対処

| エラー | 原因 | 対処 |
|---|---|---|
| `! Undefined control sequence` | タイポ / パッケージ未読み込み | スペルと `\usepackage` を確認 |
| `! Missing $ inserted` | 数式環境の外で `_` や `^` を使用 | `$...$` で囲む |
| `Font not found` | フォント名が間違い | `fc-list \| grep Harano` で確認 |
| `luatexja.sty not found` | 日本語コレクション未インストール | nix 設定を確認して switch |

## 8. 完全サンプル文書

```latex
\documentclass[a4paper,12pt]{ltjsarticle}

\usepackage[haranoaji]{luatexja-preset}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{hyperref}

\hypersetup{colorlinks=true, linkcolor=blue}

\title{LuaLaTeX サンプル文書}
\author{著者名}
\date{\today}

\begin{document}
\maketitle
\tableofcontents
\newpage

\section{はじめに}
これは LuaLaTeX による日本語組版のサンプルです。
English and 日本語を混在させることができます。

\section{数式の例}
インライン数式：$f(x) = x^2 + 2x + 1$

\[
  \sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}
\]

\section{箇条書き}
\begin{itemize}
  \item 第一項目
  \item 第二項目
\end{itemize}

\end{document}
```
