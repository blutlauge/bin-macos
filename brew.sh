#!/usr/bin/env bash

if test ! "$( which brew )"; then
    echo "Installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo -e "\\n\\nInstalling homebrew packages ..."

apps=(
    ack
    autoconf
    automake
    cmake
    ctags
    curl
    fzf
    git
    gnuplot
    htop
    mosh
    neovim
    node
    pandoc
    pandoc-citeproc
    pandoc-crossref
    pkg-config
    python
    ripgrep
    the_silver_searcher
    tmux
    tree
    vim
    wget
    zsh
    )

cask_apps=(
    emacs
    firefox
    google-chrome
    imagealpha
    imageoptim
    iterm2
    macvim
    )

for app in "${apps[@]}"; do
    app_name=$( echo "$app" | awk '{print $1}' )
    if brew list "$app_name" > /dev/null 2>&1; then
        echo "$app_name already installed ..."
    else
        brew install "$app"
    fi
done

for app in "${cask_apps[@]}"; do
    app_name=$( echo "$app" | awk '{print $1}' )
    if brew list "$app_name" > /dev/null 2>&1; then
        echo "$app_name already installed ..."
    else
        brew cask install "$app"
    fi
done

# After the install, setup fzf
echo -e "\\n\\nInstalling fzf script ..."
/usr/local/opt/fzf/install --all --no-fish

# Install neovim python libraries
echo -e "\\n\\nInstalling Neovim python libraries."
pip2 install --user neovim
pip3 install --user neovim

