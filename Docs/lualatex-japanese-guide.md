# LuaLaTeX 日本語文書ガイド（Nix home-manager + Gemini CLI 向け）

> **目的**: Nix home-manager で管理された dotfiles 環境に Gemini CLI と LuaLaTeX を同時にセットアップし、Gemini CLI から日本語 LaTeX 文書を生成・コンパイルするためのリファレンス
> これでインストールされるLatexの使い方について下記を読み込み、Latex.mdをREADMEと並列して新規作成して

---

## 1. home-manager セットアップ（dotfiles）

### 1.2 LuaLaTeX のインストール

```nix
# home.nix
{ config, pkgs, ... }:
let
  tex = pkgs.texliveSmall.withPackages (ps: with ps; [
    collection-langjapanese   # luatexja 等の日本語サポート
    collection-luatex          # LuaLaTeX エンジン
    collection-latexextra      # 汎用パッケージ群
    haranoaji                  # 原ノ味フォント（明朝・TeX Live 内蔵）
    haranoaji-extra            # 原ノ味フォント（ゴシック）
    fontspec
    hyperref
    latexmk                    # 自動コンパイルツール
  ]);
in
{
  home.packages = [ tex ];
  fonts.fontconfig.enable = true;  # システムフォントを LaTeX に認識させる
}
```


---

## 2. ドキュメントクラスの選択

| クラス | 用途 |
|---|---|
| `ltjsarticle` | 一般的な日本語論文・レポート（推奨） |
| `ltjsbook` | 書籍・長文 |
| `jlreq` | JIS X 4051 準拠の組版 |

---

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

---

## 4. LaTeX 構文リファレンス

### 4.1 文書構造

```latex
\documentclass[options]{class}   % 先頭に必須
\usepackage{package}             % プリアンブルでパッケージ読み込み
\begin{document} ... \end{document}
```

### 4.2 見出し

```latex
\section{節}
\subsection{小節}
\subsubsection{小々節}
\paragraph{段落}
```

### 4.3 テキスト装飾

```latex
\textbf{太字}
\textit{イタリック}
\underline{下線}
\texttt{等幅フォント}
{\small 小さい} {\large 大きい}
```

### 4.4 箇条書き

```latex
\begin{itemize}
  \item 項目A
  \item 項目B
\end{itemize}

\begin{enumerate}
  \item 最初
  \item 次
\end{enumerate}
```

### 4.5 数式

```latex
% インライン
$E = mc^2$

% ディスプレイ（番号なし）
\[ \int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2} \]

% ディスプレイ（番号あり）
\begin{equation}
  F = ma
\end{equation}

% 複数行
\begin{align}
  a &= b + c \\
  d &= e - f
\end{align}
```

### 4.6 表

```latex
\begin{table}[h]
  \centering
  \caption{サンプル表}
  \begin{tabular}{|l|c|r|}
    \hline
    左 & 中央 & 右 \\
    \hline
    A & B & C \\
    \hline
  \end{tabular}
\end{table}
```

### 4.7 図の挿入

```latex
\usepackage{graphicx}  % プリアンブルに追加

\begin{figure}[h]
  \centering
  \includegraphics[width=0.7\linewidth]{image.png}
  \caption{キャプション}
  \label{fig:sample}
\end{figure}
```

### 4.8 相互参照・脚注

```latex
\label{sec:intro}         % ラベル定義
\ref{sec:intro}           % 番号参照
\pageref{sec:intro}       % ページ参照

本文\footnote{これは脚注です。}
```

---

## 5. フォント設定パターン

### 5.1 原ノ味プリセット（最推奨：外部フォント不要）

```latex
\usepackage[haranoaji]{luatexja-preset}
```

### 5.2 Noto CJK（システムインストール済みの場合）

```latex
\usepackage{luatexja-fontspec}
\setmainjfont{Noto Serif CJK JP}
\setsansjfont{Noto Sans CJK JP}
\setmonojfont{Noto Sans Mono CJK JP}
```

### 5.3 手動指定（原ノ味フォントを個別に）

```latex
\usepackage{luatexja-fontspec}
\setmainjfont{HaranoAjiMincho}
\setsansjfont{HaranoAjiGothic}
```

---

## 6. コンパイル方法

### 6.1 手動コンパイル

```bash
# 基本
lualatex document.tex

# 相互参照・目次を含む場合は3回
lualatex document.tex && lualatex document.tex && lualatex document.tex
```

### 6.2 latexmk（推奨）

```bash
latexmk document.tex          # コンパイル
latexmk -pvc document.tex     # ファイル監視モード
latexmk -c document.tex       # 中間ファイル削除
latexmk -C document.tex       # PDF ごと削除
```

**`~/.latexmkrc` または プロジェクトルートに配置：**

```perl
$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error %O %S';
$pdf_mode = 4;   # 4 = lualatex
```

### 6.3 Gemini CLI から使うコマンド（Agent 向け）

```bash
# エラー時に即終了・ファイル行番号付きログ
lualatex -interaction=nonstopmode -halt-on-error -file-line-error document.tex

# エラー行だけ抽出
grep -n "^!" document.log

# 終了コードでエラー判定
lualatex -interaction=nonstopmode -halt-on-error document.tex || {
  echo "=== コンパイル失敗 ===" >&2
  grep -A2 "^!" document.log >&2
  exit 1
}
```

---

## 7. よくあるエラーと対処

| エラー | 原因 | 対処 |
|---|---|---|
| `! Undefined control sequence` | タイポ / パッケージ未読み込み | スペルと `\usepackage` を確認 |
| `! Missing $ inserted` | 数式環境の外で `_` や `^` を使用 | `$...$` で囲む |
| `Font not found` | フォント名が間違い | `fc-list \| grep Harano` で確認 |
| `luatexja.sty not found` | `collection-langjapanese` 未インストール | nix 設定を確認して `home-manager switch` |
| `no writeable cache path` | luaotfload キャッシュ問題 | `luaotfload-tool --update` を実行 |
| prettier との collision | gemini-cli と nodePackages.prettier の衝突 | `programs.gemini-cli.package` でバージョン固定 |

---

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
英語と日本語を混在させることができます（English and 日本語）。

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

\section{表}
\begin{table}[h]
  \centering
  \caption{サンプルデータ}
  \begin{tabular}{|l|c|r|}
    \hline
    名前 & 年齢 & スコア \\
    \hline
    田中 & 25 & 95 \\
    佐藤 & 30 & 87 \\
    \hline
  \end{tabular}
\end{table}

\end{document}
```

**コンパイル：**
```bash
lualatex -interaction=nonstopmode -halt-on-error document.tex
```

---

*このガイドは `~/.gemini/context/lualatex-guide.md` として配置し、Gemini CLI のコンテキストとして自動参照させることを想定しています。*
