echo "Install oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Fetching .zshrc > ~/.zshrc"
curl -fsSL https://raw.githubusercontent.com/Mitscherlich/dotfiles/dev/.zshrc -o /tmp/zshrc
echo "Backup.zshrc > ~/.zshrc.bak and replace with downloaded..."
cp $HOME/.zshrc $HOME/.zshrc.bak && cp /tmp/zshrc $HOME/.zshrc
echo "Install omz theme..."
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
echo "Install omz plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
echo "Reload omz..."
source $HOME/.zshrc
