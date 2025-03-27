## 环境配置

### 一. ble.sh 提供类似于zsh的语法高亮和交互式补全

```bash
# dependencies: git, make, gawk

git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
```

