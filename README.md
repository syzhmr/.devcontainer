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

また、コンテナ内の `~/.ssh/id_ed25519` が存在しない場合は、初回起動時に GitHub 用として使える SSH 鍵を作成します。既存の秘密鍵は上書きしません。

自動生成される秘密鍵は、初回セットアップを止めないためパスフレーズなしです。必要な場合は、あとから次のコマンドでパスフレーズを追加できます。

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519
```

作成された公開鍵は初回セットアップ時のターミナルに表示されます。GitHub で `Settings` → `SSH and GPG keys` → `New SSH key` を開き、`Key type` に `Authentication Key` を選んで登録してください。

公開鍵は次のコマンドでも確認できます。

```bash
cat ~/.ssh/id_ed25519.pub
```

`~/.ssh/id_ed25519` は秘密鍵で、他人に見せないでください。末尾に `.pub` が付く `~/.ssh/id_ed25519.pub` は公開鍵で、GitHub に登録するためのものです。

GitHub に公開鍵を登録したあと、既存の repository が HTTPS remote を使っている場合は SSH remote に切り替えます。

```bash
git remote set-url origin git@github.com:USER/REPOSITORY.git
```

Git でコミットするには、初回だけ名前とメールアドレスを設定してください。

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

公開 repository で個人メールアドレスを出したくない場合は、GitHub の no-reply メールアドレスなど、公開してよい値を設定してください。

Codex CLI を使う場合は、各ユーザーが自分の ChatGPT アカウントまたは API key でログインします。

```bash
codex login
```
