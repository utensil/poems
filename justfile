build:
    tectonic --keep-logs main.tex

prep:
    brew install font-lxgw-wenkai

xe:
    xelatex main.tex

prep-xe:
    sudo tlmgr update --self
    sudo tlmgr install fandol