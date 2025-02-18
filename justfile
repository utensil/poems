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
    rm /tmp/zhuque.zip
    rm -rf /tmp/zhuque
    curl -L https://github.com/TrionesType/zhuque/releases/download/v0.211/ZhuqueFangsong-Regular-v0.211.zip -o /tmp/zhuque.zip
    unzip -o /tmp/zhuque.zip -d /tmp/zhuque
    cp -r /tmp/zhuque/* ~/Library/Fonts/

xe:
    xelatex main.tex

prep-xe:
    sudo tlmgr update --self
    sudo tlmgr install fandol