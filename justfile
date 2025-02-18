build:
    tectonic --keep-logs main.tex

prep:
    # https://github.com/adobe-fonts/source-han-serif
    # brew install --cask font-source-han-serif
    # https://github.com/Pal3love/dream-han-cjk/
    brew install font-dream-han-sans
    brew install font-fandol 
    # https://github.com/lxgw/LxgwWenKai
    brew install font-lxgw-wenkai

xe:
    xelatex main.tex

prep-xe:
    sudo tlmgr update --self
    sudo tlmgr install fandol