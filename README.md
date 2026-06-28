# Mathematics Research Dev Container

数学科の大学院生が研究に使うための VS Code Dev Container 環境です。Python、SageMath、Lean4、LaTeX、Jupyter、Codex CLI、`pdfgrep` をひとつの Ubuntu コンテナにまとめます。

この repository は、環境構築の手順を長く説明するよりも、研究用 repository を VS Code で開いたときに同じ環境を再現できることを重視しています。

## 配布 URL

- devcontainer: <https://github.com/syzhmr/.devcontainer>
- 勉強ノートテンプレート: <https://github.com/syzhmr/codex-study-note-template>

## 前提ソフト

必須:

- VS Code
- VS Code Dev Containers 拡張機能
- コンテナ実行環境
  - macOS: Docker Desktop または Colima
  - Windows: Docker Desktop with WSL2 backend
  - Linux: Docker Engine または Docker Desktop

Windows では追加で次が必要です。

- WSL2
- Ubuntu などの Linux distribution
- VS Code WSL 拡張機能

GitHub で共有された repository を取得するには、Git CLI または GitHub Desktop を使えます。GitHub Desktop はコマンドに慣れていない人には便利です。clone した repository のフォルダーを VS Code で開いてください。

Windows では、Dev Container の性能と安定性のため、repository は WSL2 側の `/home/...` に置くことを推奨します。GitHub Desktop は通常 Windows 側の `C:\Users\...` に clone するため、その場合はビルドやファイル操作が遅くなることがあります。

## 使い方

VS Code で開くのは `.devcontainer` フォルダーそのものではなく、repository のルートです。

```text
REPOSITORY
├── .devcontainer
├── .vscode
├── examples
├── scripts
└── README.md
```

VS Code で repository を開いたら、コマンドパレットから次を実行します。

```text
Dev Containers: Reopen in Container
```

初回は Docker image の build に時間がかかります。2 回目以降は通常もっと速く起動します。

この設定は、初回起動時に用途別フォルダーやサンプルファイルを自動作成しません。Git repository でないフォルダーを開いた場合も、自動で `git init` は実行しません。

## コンテナ内でのファイル

Dev Container では、ローカルの repository がコンテナ内に mount されます。多くの場合、次のように見えます。

```text
Mac / Windows / Linux 側:
REPOSITORY

コンテナ側:
/workspaces/REPOSITORY
```

VS Code で編集しているファイルは、repository の実ファイルです。コンテナ内のターミナルで `python`、`sage`、`latexmk`、`lean` などを実行すると、その repository 内のファイルを処理します。

研究で残したいファイルは、必ず `/workspaces/REPOSITORY` の中に置いてください。`/tmp` や `/home/vscode` の中だけに置いたファイルは、コンテナの作り直しや削除で失われることがあります。

コンテナを rebuild しても、通常は repository 内のファイルは消えません。ただし、build 生成物や Jupyter notebook の出力などを Git で管理するかどうかは、研究内容に応じて決めてください。

## 入っているもの

- Python 3.13
- SageMath 10.9
- JupyterLab / Notebook
- NumPy、SciPy、SymPy、Matplotlib
- Lean4 と Lake
- `elan`
- pLaTeX、upLaTeX、LuaLaTeX
- `latexmk`
- 日本語 TeX パッケージ
- `pdfgrep`
- Git、`ripgrep`、`poppler-utils`、基本的な build tools
- Codex CLI
- Python、Jupyter、SageMath、LaTeX、Lean4 用の VS Code 拡張機能

Python と SageMath は conda-forge を使って入れています。Anaconda full distribution ではなく、必要なものを conda-forge から入れる方針です。

## 動作確認

コンテナ内の VS Code terminal で次を実行します。

```bash
bash scripts/check-examples.sh
```

この script は次を確認します。

- Python example
- SageMath example
- Lean example
- pLaTeX / upLaTeX / LuaLaTeX example
- `pdfgrep`
- Jupyter
- Codex CLI の version 表示

LaTeX の確認は一時ディレクトリで実行するため、repository に `.aux` や `.pdf` などの生成物を残しません。

## LaTeX

日本語論文や日本語ノートを書く前提で、pLaTeX、upLaTeX、LuaLaTeX を使えるようにしています。

VS Code の LaTeX Workshop では、次の recipe を共有設定に入れています。

- `latexmk (upLaTeX)`
- `latexmk (pLaTeX)`
- `latexmk (LuaLaTeX)`

新しく書く日本語文書では、upLaTeX または LuaLaTeX を使うのが扱いやすいです。既存文書が pLaTeX 前提の場合は pLaTeX recipe を使ってください。

## Lean4

Lean4 は `elan` 経由で入れています。`elan` は Lean の version 管理ツールです。

Lean project に `lean-toolchain` ファイルがある場合、`elan` はその project に指定された Lean version を使います。これにより、project ごとに Lean version を固定できます。

`mathlib` は Lean 用の大きな数学ライブラリです。本格的に Lean で数学を形式化する場合は使うことが多いですが、初回 download が大きいため、この repository の最小 example には含めていません。

## Codex CLI

Codex CLI はコンテナ内に install しています。ログインは各ユーザーが自分で行います。

```bash
codex login
```

ChatGPT アカウントまたは OpenAI API key でログインできます。ログイン情報を repository に保存しないでください。

## Git

この Dev Container は Git repository を勝手に作りません。repository の取得は Git CLI、GitHub Desktop、ZIP など、各自の方法で行ってください。

コミットする場合は、初回だけ名前とメールアドレスを設定します。

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

公開 repository で個人メールアドレスを出したくない場合は、GitHub の no-reply メールアドレスなど、公開してよい値を設定してください。

## 構成

```text
.devcontainer/
├── devcontainer.json
├── Dockerfile
├── environment.yml
└── setup-workspace.sh

.vscode/
└── settings.json

examples/
├── python/
├── sage/
├── lean/
└── latex/

scripts/
└── check-examples.sh
```

## 方針

- 再現性、分かりやすさ、初回 build 時間のバランスを重視します。
- 軽さだけを最優先にはしません。
- 用途別フォルダーは自動作成しません。
- `git init` は自動実行しません。
