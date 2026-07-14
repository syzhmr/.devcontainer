# Mathematics Research Dev Container

数学科の大学院生が研究に使うための VS Code Dev Container 環境です。Python、SageMath、Lean4、LaTeX、Jupyter、Node.js、QMD、GitHub CLI、Codex CLI、PDF/OCR ツールをひとつの Linux コンテナにまとめます。

この repository は、環境構築の手順を長く説明するよりも、研究用 repository を VS Code で開いたときに同じ環境を再現できることを重視しています。

## 配布 URL

- devcontainer: <https://github.com/syzhmr/.devcontainer>
- 勉強ノートテンプレート: <https://github.com/syzhmr/codex-study-note-template>

## 主な上流プロジェクトと配布元

この設定が直接参照または版固定するものと、FO 連携で利用する主要な上流プロジェクトをまとめます。`apt`、conda、npm が内部で取得する推移的依存関係と VS Code 拡張機能は省略しています。実際に使う版の基準は `.devcontainer/devcontainer.json`、`.devcontainer/environment.yml`、各 project の lockfile です。

| 用途 | 上流プロジェクト・配布元 | この設定での扱い |
| --- | --- | --- |
| Dev Container 基盤 | [Miniconda base image](https://github.com/devcontainers/images/tree/main/src/miniconda)、[Dev Container Features](https://github.com/devcontainers/features)、[Dev Container Specification](https://github.com/devcontainers/spec) | base image、Node.js / GitHub CLI Feature、lifecycle 設定の基準として使用 |
| Node.js / GitHub CLI | [Node.js](https://github.com/nodejs/node)、[npm CLI](https://github.com/npm/cli)、[nvm](https://github.com/nvm-sh/nvm)、[GitHub CLI](https://github.com/cli/cli) | Node.js、npm、nvm、`gh` を Dev Container Features 経由で導入 |
| Python / 数学 | [conda-forge](https://github.com/conda-forge)、[SageMath](https://github.com/sagemath/sage) | Python、SageMath、Jupyter、科学計算 package を conda から導入 |
| Lean | [elan](https://github.com/leanprover/elan)、[Lean 4](https://github.com/leanprover/lean4)、[mathlib4](https://github.com/leanprover-community/mathlib4) | `elan` と既定の Lean toolchain を導入。mathlib は project ごとの任意依存 |
| FO ローカル検索 | [QMD](https://github.com/tobi/qmd)、[QMD v2.5.3](https://github.com/tobi/qmd/releases/tag/v2.5.3)、[npm package](https://www.npmjs.com/package/@tobilu/qmd) | `@tobilu/qmd` 2.5.3 を global install。model と index は image に含めない |
| Vault template 管理 | [ShardMind](https://github.com/breferrari/shardmind)、[ShardMind v0.1.3](https://github.com/breferrari/shardmind/releases/tag/v0.1.3)、[npm package](https://www.npmjs.com/package/shardmind) | `shardmind` 0.1.3 を global install。Obsidian GUI や vault は image に含めない |
| Host 側の関連 project | [Obsidian](https://obsidian.md/)、[Obsidian Mind](https://github.com/breferrari/obsidian-mind)、[PDF++](https://github.com/RyotaUshio/obsidian-pdf-plus) | FO workflow の関連先。標準 image から install、mount、設定変更は行わない |
| Agent Memory | [TencentDB Agent Memory](https://github.com/TencentCloud/TencentDB-Agent-Memory)、[npm package](https://www.npmjs.com/package/@tencentdb-agent-memory/memory-tencentdb) | project の lockfile がある場合だけ `@tencentdb-agent-memory/memory-tencentdb` 1.0.0 の依存を復元。会話データと設定は image に含めない |
| LaTeX / PDF | [TeX Live](https://tug.org/texlive/)、[TeX Live source mirror](https://github.com/TeX-Live/texlive-source)、[Poppler](https://poppler.freedesktop.org/) | 日本語・Cyrillic TeX、`latexmk`、PDF text extraction を Ubuntu package から導入 |
| OCR / 画像処理 | [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)、[language data](https://github.com/tesseract-ocr/tessdata)、[OpenCV](https://github.com/opencv/opencv)、[ImageMagick](https://github.com/ImageMagick/ImageMagick) | OCR と画像前処理を Ubuntu package または conda から導入 |
| 任意の数式 PDF OCR | [Nougat](https://github.com/facebookresearch/nougat) | project ごとの高度オプション。標準 image には含めない |
| Codex CLI | [openai/codex](https://github.com/openai/codex)、[公式 installer](https://chatgpt.com/codex/install.sh) | 公式 installer から導入。ログイン情報は image に含めない |

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

初回は Docker image の build と、版を固定した Node.js ツールの install に時間がかかります。2 回目以降は通常もっと速く起動します。

この設定は、初回起動時に用途別フォルダーやサンプルファイルを自動作成しません。Git repository でないフォルダーを開いた場合も、自動で `git init` は実行しません。workspace 直下または `FO/` 以下に `tools/tencentdb-agent-memory/package-lock.json` がある場合だけ、その lockfile から project-local dependency を復元します。

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
- Node.js 22.22.3 と npm 10.9.8
- QMD 2.5.3
- ShardMind 0.1.3
- Lean4 と Lake
- `elan`
- pLaTeX、upLaTeX、LuaLaTeX
- `latexmk`
- 日本語 TeX パッケージと OT2 / wncyr 用 Cyrillic TeX パッケージ
- `pdfgrep`
- Git、GitHub CLI 2.94.0、OpenSSH client
- `ripgrep`、`poppler-utils`、`rsync`、`jq`、`file`、`tmux`、基本的な build tools
- Tesseract OCR と英語・日本語・日本語縦書き・OSD 用 traineddata
- OpenCV と ImageMagick 7
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
- Node.js の TypeScript type stripping
- pLaTeX / upLaTeX / LuaLaTeX example
- FO で使う OT2 encoding、wncyr、upLaTeX、upBibTeX、Mendex、Poppler の組合せ
- `pdfgrep`
- Jupyter
- Tesseract OCR と主要言語データ
- OpenCV
- QMD、ShardMind、GitHub CLI、OpenSSH、ImageMagick、`rsync`、`jq`、`file`、`tmux`
- Codex CLI の version 表示

LaTeX の確認は一時ディレクトリで実行するため、repository に `.aux` や `.pdf` などの生成物を残しません。

## LaTeX

日本語論文や日本語ノートを書く前提で、pLaTeX、upLaTeX、LuaLaTeX を使えるようにしています。

VS Code の LaTeX Workshop では、次の recipe を共有設定に入れています。

- `latexmk (upLaTeX)`
- `latexmk (pLaTeX)`
- `latexmk (LuaLaTeX)`

新しく書く日本語文書では、upLaTeX または LuaLaTeX を使うのが扱いやすいです。既存文書が pLaTeX 前提の場合は pLaTeX recipe を使ってください。

## OCR と PDF テキスト抽出

研究ノートや参考文献 PDF を扱う repository では、PDF の通常テキスト抽出と OCR を Dev Container 内で再現できるようにする方針です。

標準環境に入れる対象は次です。

- `poppler-utils`: `pdftotext`、`pdfinfo`、`pdftoppm` を使うため。
- `tesseract-ocr`: スキャン PDF の OCR を行うため。
- `tesseract-ocr-eng`: 英語資料用。
- `tesseract-ocr-jpn`: 日本語横書き資料用。
- `tesseract-ocr-jpn-vert`: 日本語縦書き資料用。
- `tesseract-ocr-osd`: orientation / script detection 用。
- OpenCV を使える Python 環境: 汎用の画像・スキャン前処理用。

一方で、各 repository 内に作る `.venv-ocr/` そのものは Dev Container に持ち込まず、Git でも追跡しません。この Dev Container は system `tesseract` と conda の OpenCV を提供します。project 固有の実行ラッパーが `.venv-ocr/` だけを要求する場合は、system tool への fallback を project 側で用意してください。

Nougat は PyTorch、CUDA、モデル取得を含み、image size と build time が大きくなりやすいため、標準 Dev Container には常設しません。数式主体の英語 PDF を `.mmd` 化したい場合だけ、project ごとの任意セットアップとして扱います。つまり、Tesseract OCR と `poppler-utils` による PDF text extraction は標準装備、Nougat は高度オプションという分担にします。

運用上は、OCR や Nougat の出力は検索補助として使います。本文、小さめの数式、定理番号、ページ見出しの候補は抽出テキストから拾ってよいですが、大きい表示数式、グラフ、可換図式、Hasse 図、符号、添字、引用箇所は原 PDF またはページ画像で確認します。FO では手書きノートを OCR にかけず、原 PDF またはページ画像を目視します。

## FO、QMD、Obsidian、Agent Memory

FO の Node.js hook とローカル検索を再現するため、Node.js 22.22.3、QMD 2.5.3、ShardMind 0.1.3 を固定して導入します。Dev Container の build と初回 setup 自体は、QMD の collection 作成、index 更新、embedding 生成を行いません。対応する bootstrap script がある repository では、内容と対象を確認してから次を実行します。

```bash
node --experimental-strip-types scripts/qmd-bootstrap.ts
```

QMD は初回の embedding や query でローカル model を download し、index と model を `~/.cache/qmd/` に置きます。この cache は image に含めず、全 repository で共有する volume も既定では作りません。機密性と必要容量を確認したうえで、必要な repository だけ個別に永続化してください。

FO の session hook や refresh worker が有効な場合は、bootstrap 後の `qmd update` や `qmd embed` が作業中に自動実行されることがあります。実行範囲と停止方法は、その repository の hook 設定と方針に従います。

FO 型の repository に `tools/tencentdb-agent-memory/package-lock.json` がある場合、初回 setup は `npm ci --prefix tools/tencentdb-agent-memory` 相当を自動実行します。LaTeX workspace の `FO/tools/tencentdb-agent-memory/` も同じように検出します。symlink 経由の directory は自動処理しません。lockfile、Node.js の版・ABI、OS、architecture が変わった場合、依存が欠落・破損している場合、または Jieba / sqlite-vec の native runtime 検査に失敗した場合に再実行し、Agent Memory の会話データ、設定、外部 port は image に組み込みません。

Obsidian 本体は GUI、WSLg/AppImage、macOS/Windows の vault path などホスト固有の条件を持つため、標準コンテナには入れません。コンテナには証拠生成や同期に必要な `magick`、`rsync`、`jq`、`file` だけを入れています。iCloud、GoodReader、Obsidian vault などの外部 mount は、各 repository で必要な許可範囲だけを明示的に追加してください。個人用の絶対 path、認証情報、SSH key はこの公開設定に含めません。

## Lean4

Lean4 は `elan` 経由で入れています。`elan` は Lean の version 管理ツールです。

Lean project に `lean-toolchain` ファイルがある場合、`elan` はその project に指定された Lean version を使います。これにより、project ごとに Lean version を固定できます。

`mathlib` は Lean 用の大きな数学ライブラリです。本格的に Lean で数学を形式化する場合は使うことが多いですが、初回 download が大きいため、この repository の最小 example には含めていません。

`mathlib` project の `.lake/` も image には含めません。fresh clone では project の説明を確認し、通常は project directory で次を実行します。

```bash
lake update
lake exe cache get
```

repository が別 machine の絶対 path を指す `.lake` symlink を追跡している場合、その symlink は container 内では再利用できません。依存取得前に repository 側で portable な状態へ直してください。

## Codex CLI

Codex CLI はコンテナ内に install しています。ログインは各ユーザーが自分で行います。

```bash
codex login
```

ChatGPT アカウントまたは OpenAI API key でログインできます。ログイン情報を repository に保存しないでください。

## Git

この Dev Container は Git repository を勝手に作りません。repository の取得は Git CLI、GitHub Desktop、ZIP など、各自の方法で行ってください。

GitHub CLI は入っていますが、GitHub の token や SSH key は入っていません。必要な場合はコンテナ内で `gh auth login` を実行するか、安全な credential forwarding を個別に設定してください。

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
├── latex/
└── node/

scripts/
└── check-examples.sh
```

## 方針

- 再現性、分かりやすさ、初回 build 時間のバランスを重視します。
- 軽さだけを最優先にはしません。
- 用途別フォルダーは自動作成しません。
- `git init` は自動実行しません。
- Dev Container の build と初回 setup では、QMD の model download と index 作成を自動実行しません。
- Obsidian GUI、個人用 mount、認証情報は image に含めません。
- Nougat/CUDA は標準環境に常設しません。
