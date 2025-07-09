# ========================================== #
#      Makefile for Dotfiles Management      #
# ========================================== #

UNAME_S 		:= $(shell uname -s)
DOTFILE_COMMON 	:= .gitconfig .tmux.conf .vimrc

### Setup Paths ###
BLE_SH_REPO		:= git@github.com:akinomyoga/ble.sh.git
BLE_SH_DIR		:= $(HOME)/Documents/softwares/ble.sh

DOTFILES_DIR 	:= $(HOME)/dotfiles/src
LOCAL_BIN_DIR 	:= $(HOME)/.local/bin
LOCAL_SHARE_DIR := $(HOME)/.local/share 

ifeq ($(UNAME_S),Linux)
	SHELL := /bin/bash
    DOTFILE_LIST := $(DOTFILE_COMMON) .bashrc 
else ifeq ($(UNAME_S),Darwin)
    DOTFILE_LIST := $(DOTFILE_COMMON) .zshrc
else
    $(error "Unsupported OS: $(UNAME_S). Only Linux and macOS.")
    DOTFILE_LIST := $(DOTFILE_COMMON)
endif

.PHONY: all env clean install-ble link-dotfiles unlink-dotfiles

all: env

### env: Link dotfiles & install ble.sh ###
env: link-dotfiles install-ble
	@echo -e "INFO: Linking dotfiles, installing ble.sh...\n"

### Link dotfiles ###
link-dotfiles:
	@echo -e "INFO: Linking dotfiles..."
	@for file in $(DOTFILE_LIST); do \
		if [ -f "$(HOME)/$$file" ] && [ ! -L "$(HOME)/$$file" ]; then \
			echo "INFO: Copying $(HOME)/$$file to $(HOME)/$$file.bak"; \
			mv "$(HOME)/$$file" "$(HOME)/$$file.bak"; \
		fi; \
		if [ ! -L "$(HOME)/$$file" ]; then \
			echo "INFO: Making symbolic link $(HOME)/$$file -> $(DOTFILES_DIR)/$$file"; \
			ln -s "$(DOTFILES_DIR)/$$file" "$(HOME)/$$file"; \
		else \
			echo "INFO: $(HOME)/$$file exist, skip."; \
		fi; \
	done
	@echo -e "INFO: Dotfiles symlink complete! \\(^_^)/ \n"

### Unlink dotfiles ###
unlink-dotfiles:
	@echo -e "INFO: Unlinking dotfiles..."
	@for file in $(DOTFILE_LIST); do \
		if [ -L "$(HOME)/$$file" ] && [ "$$(readlink "$(HOME)/$$file")" = "$(DOTFILES_DIR)/$$file" ]; then \
			echo "INFO: Removing $(HOME)/$$file"; \
			rm "$(HOME)/$$file"; \
		fi; \
		if [ -f "$(HOME)/$$file.bak" ]; then \
			echo "INFO: Recovering $(HOME)/$$file.bak to $(HOME)/$$file"; \
			mv "$(HOME)/$$file.bak" "$(HOME)/$$file"; \
		fi; \
	done
	@echo -e "INFO: Dotfiles Unlinked\n"

### Install ble.sh for Linux ###
install-ble:
ifeq ($(UNAME_S), Linux)
	@echo "INFO: Installing ble.sh..."
	@if [ ! -d "$(BLE_SH_DIR)" ]; then \
		echo "INFO: Cloning ble.sh repo..."; \
		git clone --recursive --depth 1 --shallow-submodules $(BLE_SH_REPO) $(BLE_SH_DIR); \
	else \
		echo "WARNING: ble.sh exist, skip clone."; \
	fi
	@if [ -d "$(BLE_SH_DIR)" ]; then \
		echo "INFO: Building ble.sh..."; \
		make -C $(BLE_SH_DIR) install PREFIX=$(HOME)/.local; \
		grep -q 'source ~/.local/share/blesh/ble.sh' ~/.bashrc || echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc; \
	else \
		echo "ERROR: Can't find directory ble.sh."; \
		exit 1; \
	fi
	@echo "INFO: ble.sh is installed."
else
	@echo "WARNING: Current OS is $(UNAME_S), skip ble.sh."
endif

### Uninstall ble.sh ###
uninstall-ble:
	@echo "INFO: Uninstalling ble.sh..."
	@if [ -d "$(BLE_SH_DIR)" ]; then \
		make -C $(BLE_SH_DIR) uninstall PREFIX=$(HOME)/.local || true; \
	fi
	@if [ -d "$(LOCAL_SHARE_DIR)/blesh" ]; then \
		echo "INFO: Removing ~/.local/share/blesh dir..."; \
		rm -rf "$(LOCAL_SHARE_DIR)/blesh"; \
	fi
	@if [ -d "$(LOCAL_BIN_DIR)/blesh" ]; then \
		echo "INFO: Removing ~/.local/bin/blesh dir..."; \
		rm -rf "$(LOCAL_BIN_DIR)/blesh"; \
	fi
	@if [ "$(UNAME_S)" = "Linux" ] || [ "$(UNAME_S)" = "Darwin" ]; then \
		if grep -q 'source ~/.local/share/blesh/ble.sh' ~/.bashrc; then \
			echo "从 ~/.bashrc 移除 ble.sh 源行..."; \
			sed -i '/source ~\.local\/share\/blesh\/ble\.sh/d' ~/.bashrc; \
		fi; \
	fi
	@echo "INFO: ble.sh uninstalled"

### remove all symlink and uninstall ble.sh ###
clean: unlink-dotfiles uninstall-ble
	@echo "INFO: clear all"
	@if [ -d "$(BLE_SH_DIR)" ]; then \
		echo "INFO: Removing ble.sh repo dir..."; \
		rm -rf "$(BLE_SH_DIR)"; \
	fi