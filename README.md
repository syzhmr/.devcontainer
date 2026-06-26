# Dev Container

この Dev Container は、数学科の大学院生が VS Code 上ですぐに LaTeX、Python、SageMath、Lean4 を使い始められる Ubuntu ベースの開発環境です。Git で変更履歴を記録しながら、計算、証明、文書作成を同じ環境で進められるようにします。

インストールされる主なものは次の通りです。

- Python 3.13
- SageMath 10.9
- elan 経由の Lean 4.31.0 と Lake
- Jupyter
- LaTeX Workshop 用の LaTeX ツール一式と日本語 TeX パッケージ
- `pdfgrep`、`ripgrep`、`poppler-utils`
- Git、OpenSSH、基本的なビルドツール
- Codex CLI
- Python、Jupyter、SageMath、LaTeX、Lean4 用の VS Code 拡張機能

特定のサンプルファイルが存在することは前提にしていません。

## 使い方

1. Docker Desktop または Colima をインストールします。
2. VS Code をインストールします。
3. VS Code の Dev Containers 拡張機能をインストールします。
4. この `.devcontainer` フォルダーが入っているフォルダーを VS Code で開きます。
5. コマンドパレットから `Dev Containers: Reopen in Container` を実行します。

初回起動時は Docker image を作成するため、ダウンロードとインストールに時間がかかります。2 回目以降は通常もっと速く起動します。

## 動作確認

コンテナが起動したら、VS Code のターミナルで次を実行します。

```bash
python --version
sage --version
lean --version
lake --version
latexmk -version
pdfgrep --version
codex --version
```

初回起動時に、開いたフォルダーの直下へ `Python`、`LaTeX`、`SageMath`、`Lean4` フォルダーを作成します。まだ Git repository でない場合は `git init` も実行します。

Git でコミットするには、初回だけ名前とメールアドレスを設定してください。

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Codex CLI を使う場合は、各ユーザーが自分の ChatGPT アカウントまたは API key でログインします。

```bash
codex login
```
