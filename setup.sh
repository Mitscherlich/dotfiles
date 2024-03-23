set -e

# clone into tmp
git clone https://github.com/Mitscherlich/dotfiles.git /tmp/dotfiles && cd /tmp/dotfiles
cp -r .config $HOME/.config && cp -r .local $HOME/.local

# setup macos
source macos.sh

# setup homebrew
source homebrew.sh

# setup oh-my-zsh
source ohmyz.sh

# cleanup
rm -rf /tmp/dotfiles
echo "Done."
