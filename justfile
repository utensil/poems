dev: build
    open main.pdf

build:
    tectonic --keep-logs main.tex

prep:
    #!/usr/bin/env zsh
    # https://github.com/adobe-fonts/source-han-serif
    # brew install --cask font-source-han-serif
    # https://github.com/Pal3love/dream-han-cjk/
    brew install font-dream-han-sans
    brew install font-fandol
    # https://github.com/lxgw/LxgwWenKai
    brew install font-lxgw-wenkai

prep-zq:
    # https://github.com/TrionesType/zhuque
    rm /tmp/zhuque.zip || true
    rm -rf /tmp/zhuque || true
    curl -L https://github.com/TrionesType/zhuque/archive/refs/tags/v0.212.zip -o /tmp/zhuque.zip
    mkdir -p /tmp/zhuque
    unzip -o /tmp/zhuque.zip -d /tmp/zhuque
    cp -fr /tmp/zhuque/* ~/Library/Fonts/

xe:
    xelatex main.tex

prep-xe:
    brew install mactex
    sudo tlmgr update --self
    sudo tlmgr install fandol

prep-tc:
    curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh
    sudo mv tectonic /usr/local/bin/

push:
    jj bs master -r @-
    jj psb master
