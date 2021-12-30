set -e

echo "使用 USTC 镜像安装 Homebrew"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

/bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/Homebrew/install@HEAD/install.sh)"

echo "使用 USTC 镜像安装 Cask 软件源"
brew tap --custom-remote --force-auto-update homebrew/cask https://mirrors.ustc.edu.cn/homebrew-cask.git

echo "使用 USTC 镜像安装 Cask Version 软件源"
brew tap --custom-remote --force-auto-update homebrew/cask-versions https://mirrors.ustc.edu.cn/homebrew-cask-versions.git

echo "使用 Homebrew 安装必要的工具软件"
brew install --cask qq wechat wechatwork wechatwebdevtools neteasemusic baiduinput
brew install --cask alfred appcleaner thunderbird firefox google-chrome iterm2 tabby sublime-text visual-studio-code
brew install --cask karabiner-elements keka typora notion obsidian shadowsocksx-ng teamviewer vmware-fusion

echo "安装 oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# echo "下载 .zshrc"
# TODO

echo "完成"
