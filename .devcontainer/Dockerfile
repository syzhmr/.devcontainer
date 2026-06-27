FROM mcr.microsoft.com/devcontainers/miniconda:1.2.7-3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode
ARG DEFAULT_LEAN_TOOLCHAIN=leanprover/lean4:v4.31.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bubblewrap \
        build-essential \
        ca-certificates \
        curl \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        git \
        latexmk \
        make \
        pdfgrep \
        perl \
        poppler-utils \
        ripgrep \
        texlive-fonts-recommended \
        texlive-lang-japanese \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-luatex \
        texlive-science \
        texlive-xetex \
    && rm -rf /var/lib/apt/lists/*

COPY environment.yml /tmp/environment.yml

RUN conda config --system --add channels conda-forge \
    && conda config --system --set channel_priority strict \
    && conda env update -n base -f /tmp/environment.yml \
    && conda clean -afy

USER ${USERNAME}
ENV PATH="/home/${USERNAME}/.local/bin:/home/${USERNAME}/.elan/bin:/opt/conda/bin:${PATH}"

RUN curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
    | sh -s -- -y --default-toolchain "${DEFAULT_LEAN_TOOLCHAIN}" \
    && lean --version \
    && lake --version

RUN mkdir -p "/home/${USERNAME}/.local/bin" \
    && curl -fsSL https://chatgpt.com/codex/install.sh \
    | CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR="/home/${USERNAME}/.local/bin" sh \
    && codex --version

WORKDIR /workspaces
