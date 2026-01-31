# 定义 YAML 配置文件路径
CONFIG_YAML := ./config.yaml

# 检查 Go 版本 yq 是否安装
ifeq (, $(shell which yq))
$(error "请先安装 Go 版本 yq 工具，安装指南：https://github.com/mikefarah/yq")
endif

APP_NAME := $(shell yq eval '.app.name' $(CONFIG_YAML))
APP_VERSION := $(shell yq eval '.app.version' $(CONFIG_YAML))
APP_DESCRIPTION := $(shell yq eval '.app.description' $(CONFIG_YAML))
APP_SOURCE := $(shell yq eval '.app.source' $(CONFIG_YAML))
APP_AUTHOR := $(shell yq eval '.app.author' $(CONFIG_YAML))
APP_VENDOR := $(shell yq eval '.app.vendor' $(CONFIG_YAML))
APP_LICENSE := $(shell yq eval '.app.license' $(CONFIG_YAML))
APP_DOCS := $(shell yq eval '.app.docs' $(CONFIG_YAML))
ARCHITECTURES := $(shell yq eval '.build.architectures | join(" ")' $(CONFIG_YAML))
FILES_EXT := $(shell yq eval '.build.extra_files | map(basename | split(".")[-1]) | unique | join(" ")' $(CONFIG_YAML))


# 变量定义
BIN_DIR := $(abspath bin)
TEMP_DIR := .tmp
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

APP_VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0")
APP_NICKNAME ?= unknown
APP_DESCRIPTION ?= unknown
APP_SOURCE ?= unknown
APP_AUTHOR ?= unknown
APP_VENDOR ?= unknown
APP_LICENSE ?= unknown
APP_DOCS ?= unknown

# 默认架构列表
ARCHITECTURES ?= amd64 arm64
IMAGE_NAME ?= $(APP_NAME):$(APP_VERSION)
TAR_PREFIX := $(BIN_DIR)/image_

# 颜色定义
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: all build package clean help

# 默认目标
all: clean build package

# 显示帮助信息
help:
	@echo "$(GREEN)可用命令:$(NC)"
	@echo "  make all          - 构建镜像并打包（默认）"
	@echo "  make build        - 仅构建镜像"
	@echo "  make package          - 仅将镜像文件打包"
	@echo "  make clean        - 清理构建文件"
	@echo "  make help         - 显示此帮助信息"


# 创建必要的目录
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(TEMP_DIR):
	@mkdir -p $(TEMP_DIR)

# 检查必需配置变量
check-config:
ifndef APP_NAME
	$(error APP_NAME 未定义！)
endif

# 构建所有架构的镜像
build: check-config $(BIN_DIR)
	@echo "$(GREEN)构建镜像...$(NC)"
	@echo "版本: $(APP_VERSION)"
	@echo "构建时间: $(BUILD_TIME)"
	@echo "支持的架构: $(ARCHITECTURES)"
	
	@for arch in $(ARCHITECTURES); do \
		echo "$(YELLOW)正在构建 $$arch 架构...$(NC)"; \
		TAR_FILE="$(TAR_PREFIX)$$arch.tar"; \
		case $$arch in \
			amd64) \
				BUILDARCH="amd64"; \
				TARGETARCH="amd64"; \
				;; \
			arm64) \
				BUILDARCH="arm64"; \
				TARGETARCH="arm64"; \
				;; \
			*) \
				echo "$(RED)不支持的架构: $$arch$(NC)"; \
				continue; \
				;; \
		esac; \
		echo "目标文件: $$TAR_FILE"; \
		docker buildx build \
			--platform linux/$$arch \
			--output type=docker,dest=$$TAR_FILE \
			--build-arg TARGETOS=linux \
			--build-arg TARGETARCH=$$TARGETARCH \
			--build-arg APP_VERSION=$(APP_VERSION) \
			--build-arg BUILD_TIME=$(BUILD_TIME) \
			--build-arg APP_NAME="$(APP_NAME)" \
			--build-arg APP_VERSION="$(APP_VERSION)" \
			--build-arg APP_DESCRIPTION="$(APP_DESCRIPTION)" \
			--build-arg APP_SOURCE="$(APP_SOURCE)" \
			--build-arg APP_AUTHOR="$(APP_AUTHOR)" \
			--build-arg APP_VENDOR="$(APP_VENDOR)" \
			--build-arg APP_LICENSE="$(APP_LICENSE)" \
			--build-arg APP_DOCS="$(APP_DOCS)" \
			. || exit 1; \
		echo "$(GREEN)$$arch 架构构建完成$(NC)\n"; \
	done
	@echo "$(GREEN)所有架构构建完成！$(NC)"


package: $(BIN_DIR)
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	$(eval APP_NAME := $(shell echo "$(APP_NAME)" | sed 's/[^a-zA-Z0-9.-]/-/g'))
	$(eval TMP_DIR := $(shell mktemp -d))
	$(eval APP_CONFIG := $(BIN_DIR)/../config.yaml)
	
	@for arch in $(ARCHITECTURES); do \
		IMG_TAR="$(BIN_DIR)/image_$$arch.tar"; \
		CPK_FILE="$(BIN_DIR)/$(APP_NAME)_$(APP_VERSION)_$$arch.cpk"; \
		TMP_CPK_DIR="$(TMP_DIR)/$(APP_NAME)_$$arch"; \
		echo "处理架构 $$arch..."; \
		mkdir -p "$$TMP_CPK_DIR"; \
		cd $(BIN_DIR)/..; \
		cp "$$IMG_TAR" "$$TMP_CPK_DIR/image_$$arch.tar"; \
		cp "$(APP_CONFIG)" "$$TMP_CPK_DIR/"; \
		if [ -n "$(FILES_EXT)" ]; then \
			for file in $(FILES_EXT); do \
				cp "$$file" "$$TMP_CPK_DIR/" 2>/dev/null || true; \
			done; \
		fi; \
		cd "$$TMP_CPK_DIR" && tar -zcf "image_$$arch.tar.gz" *; \
		cd $(BIN_DIR)/..; \
		mv "$$TMP_CPK_DIR/image_$$arch.tar.gz" "$$CPK_FILE"; \
		echo "已创建: $$CPK_FILE"; \
		cd $(BIN_DIR)/..; \
	done
	@echo "正在创建多架构包..."
	$(eval MULTI_ARCH_CPK := $(BIN_DIR)/$(APP_NAME)_$(APP_VERSION)_universal.cpk)
	$(eval MULTI_TMP_DIR := $(TMP_DIR)/multiarch_unified)
	@mkdir -p "$(MULTI_TMP_DIR)"
	@cp "$(APP_CONFIG)" "$$MULTI_TMP_DIR/" || { echo "错误：无法复制config.yaml"; exit 1; }
	@if [ -n "$(FILES_EXT)" ]; then \
		echo "复制扩展文件: $(FILES_EXT)"; \
		for file in $(FILES_EXT); do \
			cp "$$file" "$$MULTI_TMP_DIR/" 2>/dev/null || echo "警告：跳过不存在的扩展文件 $$file"; \
		done; \
	fi
	@for arch in $(ARCHITECTURES); do \
		IMG_TAR="$(BIN_DIR)/image_$$arch.tar"; \
		if [ -f "$$IMG_TAR" ]; then \
			cp "$$IMG_TAR" "$$MULTI_TMP_DIR/image_$$arch.tar" || { echo "错误：无法复制$$IMG_TAR"; exit 1; }; \
			echo "已收集架构 $$arch 的镜像文件"; \
		else \
			echo "错误：架构 $$arch 的镜像文件 $$IMG_TAR 不存在"; exit 1; \
		fi; \
	done
	@cd $(MULTI_TMP_DIR) && tar -zcf "../multiarch.tar.gz" *
	@mv "$(TMP_DIR)/multiarch.tar.gz" "$$MULTI_ARCH_CPK" || { echo "错误：无法生成多架构cpk包"; exit 1; }
	@echo "已创建多架构统一包: $$MULTI_ARCH_CPK"
	
	@rm -rf $(TMP_DIR)
	@echo "打包完成!"

# 用于分割架构列表的逗号变量
comma := ,




# 清理构建文件
clean:
	@echo "$(YELLOW)清理构建文件...$(NC)"
	@rm -rf $(BIN_DIR) $(TEMP_DIR) 2>/dev/null || true
	@echo "$(GREEN)清理完成！$(NC)"