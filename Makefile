# 包含配置文件
include config.mk

# 变量定义
BIN_DIR := bin
TEMP_DIR := .tmp
APP_VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0")
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

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
	@echo ""
	@echo "$(YELLOW)配置变量（在config.mk中设置）:$(NC)"
	@echo "  ARCHITECTURES   - 目标架构列表（默认：amd64 arm64）"
	@echo "  APP_NAME        - 应用唯一名称"
	@echo "  APP_VERSION     - 应用版本"
	@echo "  APP_NICKNAME    - 应用显示名称"
	@echo "  APP_DESCRIPTION - 应用描述"
	@echo "  APP_SOURCE      - 应用源码地址"
	@echo "  APP_AUTHOR      - 应用作者"
	@echo "  APP_VENDOR      - 供应商"
	@echo "  APP_LICENSE     - 许可证"
	@echo "  APP_DOCS        - 文档地址"

# 创建必要的目录
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(TEMP_DIR):
	@mkdir -p $(TEMP_DIR)

# 检查必需配置变量
check-config:
ifndef APP_NAME
	$(error APP_NAME 未在 config.mk 中定义！)
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



include config.mk

package:
	# 1. 生成 manifest.json
	$(eval APP_NAME := $(shell echo "$(APP_NAME)" | sed 's/[^a-zA-Z0-9.-]/-/g'))
	$(eval TMP_DIR := $(shell mktemp -d))
	$(eval MANIFEST_JSON := $(TMP_DIR)/manifest.json)
	
	@echo "生成 manifest.json..."
	@echo '{' > $(MANIFEST_JSON)
	@echo '  "name": "$(APP_NAME)",' >> $(MANIFEST_JSON)
	@echo '  "version": "$(APP_VERSION)",' >> $(MANIFEST_JSON)
	@echo '  "nickname": "$(APP_NICKNAME)",' >> $(MANIFEST_JSON)
	@echo '  "description": "$(APP_DESCRIPTION)",' >> $(MANIFEST_JSON)
	@echo '  "source": "$(APP_SOURCE)",' >> $(MANIFEST_JSON)
	@echo '  "author": "$(APP_AUTHOR)",' >> $(MANIFEST_JSON)
	@echo '  "vendor": "$(APP_VENDOR)",' >> $(MANIFEST_JSON)
	@echo '  "license": "$(APP_LICENSE)",' >> $(MANIFEST_JSON)
	@echo '  "docs": "$(APP_DOCS)",' >> $(MANIFEST_JSON)
	@echo '  "depends_opkg": "$(DEPENDS_OPKG)",' >> $(MANIFEST_JSON)
	@echo '  "depends_capp": "$(DEPENDS_CAPP)",' >> $(MANIFEST_JSON)
	@echo '  "architectures": "$(ARCHITECTURES)",' >> $(MANIFEST_JSON)
	@echo '  "files_ext": "$(FILES_EXT)"' >> $(MANIFEST_JSON)
	@echo '}' >> $(MANIFEST_JSON)
	
	# 2. 处理每个架构的镜像文件
	$(foreach arch,$(subst $(comma), ,$(ARCHITECTURES)),\
		$(eval IMG_TAR := $(BIN_DIR)/image_$(arch).tar)\
		$(eval CPK_FILE := $(BIN_DIR)/$(APP_NAME)_$(APP_VERSION)_$(arch).cpk)\
		$(eval TMP_CPK_DIR := $(TMP_DIR)/$(APP_NAME)_$(arch))\
		
		@echo "处理架构 $(arch)..."\
		mkdir -p $(TMP_CPK_DIR)\
		# 复制镜像文件并重命名\
		cp $(IMG_TAR) $(TMP_CPK_DIR)/image.tar\
		# 复制 manifest.json\
		cp $(MANIFEST_JSON) $(TMP_CPK_DIR)/\
		# 复制 FILES_EXT 中指定的文件\
		$(if $(FILES_EXT),\
			$(foreach file,$(FILES_EXT),\
				cp $(file) $(TMP_CPK_DIR)/ 2>/dev/null || true\
			)\
		)\
		
		# 打包为 gz 文件
		cd $(TMP_CPK_DIR) && tar -czf image_$(arch).gz *\
		# 重命名为 cpk\
		mv $(TMP_CPK_DIR)/image_$(arch).gz $(CPK_FILE)\
		@echo "已创建: $(CPK_FILE)"\
	)
	
	# 3. 清理临时目录
	rm -rf $(TMP_DIR)
	@echo "打包完成!"

# 定义 package 目标
.PHONY: package
package:
	$(call package)

# 用于分割架构列表的逗号变量
comma := ,




# 清理构建文件
clean:
	@echo "$(YELLOW)清理构建文件...$(NC)"
	@rm -rf $(BIN_DIR) $(TEMP_DIR) 2>/dev/null || true
	@echo "$(GREEN)清理完成！$(NC)"