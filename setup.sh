set -e

echo "Install Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Install oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Fetching .zshrc > ~/.zshrc"
mkdir -p $HOME/.cache && curl -fsSL https://raw.githubusercontent.com/Mitscherlich/dotfiles/dev/.zshrc -o $HOME/.cache/zshrc
echo "Backup.zshrc > ~/.zshrc.bak and replace with downloaded..."
cp $HOME/.zshrc $HOME/.zshrc.bak
cp $HOME/.cache/zshrc $HOME/.zshrc
echo "Install zsh-theme spaceship..."
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
echo "Install zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
echo "Reload oh-my-zsh..."
source $HOME/.zshrc

echo "Install Packages..."
brew bundle install

echo "Done."
