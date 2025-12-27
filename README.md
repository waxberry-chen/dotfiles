# Dotfiles

[toc]

## 一. Intro

这个仓库是我的dotfiles, 包括: 

- ubuntu的bash和macOS的zsh的**高亮和自动补全**. 
- tmux
- gitconfig

## 二. 用法

配置: 

```bash
git clone git@github.com:waxberry-chen/dotfiles.git ~/dotfiles
cd ~/dotfiles
make env
# 会为~/dotfiles/src中的配置文件创建软链接, 并为Linux系统安装ble.sh. 
```

解除配置:

```bash
cd ~/dotfiles
make clean
```

