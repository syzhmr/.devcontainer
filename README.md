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

## 共通の考え方

Windows 版と Mac 版で別々の Dev Container を作る必要はありません。この設定は Ubuntu ベースの Linux コンテナを作るためのもので、Windows でも Mac でも同じ `.devcontainer` フォルダーを使います。

VS Code で開くのは、`.devcontainer` フォルダーそのものではなく、`.devcontainer` フォルダーが入っている作業フォルダーです。

```text
作業フォルダー
└── .devcontainer
    ├── devcontainer.json
    ├── Dockerfile
    ├── environment.yml
    └── setup-workspace.sh
```

初回起動時は Docker image を作成するため、ダウンロードとインストールに時間がかかります。2 回目以降は通常もっと速く起動します。

## Windows 版

Windows では、Docker Desktop の WSL2 backend を使う方法を推奨します。

### WSL2 とは

WSL2 は、Windows 上で Linux 環境を動かすための仕組みです。この Dev Container は Ubuntu ベースの Linux コンテナなので、Windows 上では Docker Desktop が WSL2 を土台にして Linux コンテナを起動します。

関係は次のようになります。

```text
Windows
├── VS Code
├── Docker Desktop
│   └── WSL2 backend
│       └── Dev Container の Ubuntu コンテナ
└── WSL2 Ubuntu
    └── 作業フォルダーを置く場所
```

「WSL2 上に Dev Container を置く」というより、正確には「WSL2 側に置いた作業フォルダーを VS Code で開き、Docker Desktop が Dev Container を起動する」という使い方です。

### なぜ WSL2 側に作業フォルダーを置くのか

作業フォルダーは、できれば Windows 側の `C:\Users\...` ではなく、WSL2 Ubuntu 側の `/home/USER/...` に置いてください。

推奨:

```text
/home/USER/work/my-project
```

Windows から見た場合:

```text
\\wsl$\Ubuntu\home\USER\work\my-project
```

避けたい例:

```text
C:\Users\USER\Documents\my-project
/mnt/c/Users/USER/Documents/my-project
```

Windows 側のファイルを Linux コンテナから使うと、ファイル操作が遅くなったり、権限や改行コードでつまずいたりすることがあります。LaTeX のビルド、Python パッケージ、Git、Jupyter、Lean のように多くのファイルを扱う用途では、WSL2 側に置く方が安定しやすいです。

### 1. WSL2 と Ubuntu を入れる

PowerShell を管理者として開き、次を実行します。

```powershell
wsl --install -d Ubuntu
```

インストール後、Windows を再起動します。Ubuntu を初回起動すると、Linux 用のユーザー名とパスワードを作成する画面が出ます。ここで作るユーザーは Windows のユーザーとは別物です。

確認するには、PowerShell で次を実行します。

```powershell
wsl -l -v
```

Ubuntu の `VERSION` が `2` になっていれば WSL2 です。もし `1` になっている場合は、次で WSL2 に切り替えます。

```powershell
wsl --set-version Ubuntu 2
wsl --set-default-version 2
```

### 2. Docker Desktop を入れる

Docker Desktop for Windows をインストールして起動します。

Docker Desktop の設定で次を確認します。

- `Settings` → `General` → `Use WSL 2 based engine` が有効
- `Settings` → `Resources` → `WSL Integration` で Ubuntu との連携が有効

環境によっては、WSL2 backend が標準で有効になっていて、`Use WSL 2 based engine` が表示されないことがあります。その場合はそのままで構いません。

WSL2 Ubuntu のターミナルで次を実行し、Docker に接続できることを確認します。

```bash
docker version
```

`Cannot connect to the Docker daemon` のようなエラーが出る場合は、Docker Desktop が起動しているか、WSL Integration が有効かを確認してください。

### 3. VS Code と拡張機能を入れる

Windows 側に VS Code をインストールします。WSL2 の Ubuntu 内に VS Code 本体を別途インストールする必要はありません。

VS Code には次の拡張機能を入れます。

- WSL
- Dev Containers

VS Code のインストール時に `code` コマンドを PATH に追加しておくと、WSL2 のターミナルから `code .` で VS Code を開けます。

### 4. 作業フォルダーを WSL2 側に置く

Ubuntu ターミナルを開き、作業フォルダーを作ります。

```bash
mkdir -p ~/work
cd ~/work
```

GitHub などから repository を取得する場合は、ここで clone します。

```bash
git clone https://github.com/USER/REPOSITORY.git
cd REPOSITORY
```

WSL2 Ubuntu 側に SSH 鍵を設定済みの場合は、`git@github.com:USER/REPOSITORY.git` のような SSH URL で clone しても構いません。SSH 鍵がまだない場合は、まず HTTPS で取得する方が簡単です。

まだ repository を使わずに始める場合は、作業フォルダーを作って、その中に `.devcontainer` フォルダーを配置します。

```bash
mkdir my-project
cd my-project
```

### 5. VS Code で WSL2 側の作業フォルダーを開く

Ubuntu ターミナルで、作業フォルダーに入った状態で次を実行します。

```bash
code .
```

初回は VS Code Server が WSL2 Ubuntu 側に自動で入ります。VS Code の左下に `WSL: Ubuntu` のような表示が出ていれば、WSL2 側のフォルダーを開けています。

### 6. Dev Container を起動する

VS Code のコマンドパレットを開き、次を実行します。

```text
Dev Containers: Reopen in Container
```

コンテナのビルドが終わると、VS Code の左下表示が `Dev Container: Mathematics Dev Environment` のように変わります。この状態では、VS Code のターミナル、Python、LaTeX、Lean、SageMath はコンテナ内で動きます。

## Mac 版

Mac では WSL2 は使いません。Docker Desktop または Colima で Linux コンテナを動かします。

### 1. Docker を用意する

通常は Docker Desktop for Mac を使うのが簡単です。Apple Silicon Mac と Intel Mac でインストーラーが分かれているため、自分の Mac に合うものを選びます。

Docker Desktop を起動したあと、ターミナルで次を確認します。

```bash
docker version
```

Colima を使う場合は、Docker CLI と Colima をインストールしてから起動します。

```bash
colima start
docker version
```

Docker Desktop と Colima を同時に使うと Docker context が分かりにくくなることがあります。通常はどちらか一方に決めて使ってください。

### 2. VS Code と拡張機能を入れる

Mac に VS Code をインストールし、次の拡張機能を入れます。

- Dev Containers

Windows と違い、WSL 拡張機能は不要です。

### 3. 作業フォルダーを開く

作業フォルダーの中に `.devcontainer` フォルダーを配置します。

```text
my-project
└── .devcontainer
```

VS Code で `my-project` を開きます。ターミナルから開く場合は、作業フォルダーで次を実行します。

```bash
code .
```

### 4. Dev Container を起動する

VS Code のコマンドパレットを開き、次を実行します。

```text
Dev Containers: Reopen in Container
```

コンテナのビルドが終わると、VS Code のターミナルや拡張機能はコンテナ内の Ubuntu 環境を使います。

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

## GitHub 用 SSH 鍵

コンテナ内の `~/.ssh/id_ed25519` が存在しない場合は、初回起動時に GitHub 用として使える SSH 鍵を作成します。既存の秘密鍵は上書きしません。

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

## Codex CLI

Codex CLI を使う場合は、各ユーザーが自分の ChatGPT アカウントまたは API key でログインします。

```bash
codex login
```

## 参考

- [WSL のインストール](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Docker Desktop WSL2 backend](https://docs.docker.com/desktop/features/wsl/)
- [Docker Desktop WSL2 best practices](https://docs.docker.com/desktop/features/wsl/best-practices/)
- [VS Code: Developing in WSL](https://code.visualstudio.com/docs/remote/wsl)
- [VS Code: Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Desktop on Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
