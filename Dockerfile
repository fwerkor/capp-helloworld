# 多阶段构建：编译阶段
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

# 安装必要的工具
RUN apk add --no-cache git ca-certificates

# 设置工作目录
WORKDIR /app

# 复制go模块文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 构建参数
ARG TARGETOS
ARG TARGETARCH
ARG APP_VERSION=unknown
ARG BUILD_TIME=unknown
ARG APP_NAME
ARG APP_VERSION
ARG APP_NICKNAME
ARG APP_DESCRIPTION
ARG APP_SOURCE
ARG APP_AUTHOR
ARG APP_VENDOR
ARG APP_LICENSE
ARG APP_DOCS
ARG BUILD_TIME=$(date +%Y%m%d-%H%M%S)

# 编译应用
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-w -s \
    -X 'main.Version=${APP_VERSION}' \
    -X 'main.BuildTime=${BUILD_TIME}' \
    -X 'main.AppName=${APP_NAME}' \
    -X 'main.AppDescription=${APP_DESCRIPTION}'" \
    -o /output/app .

# 多阶段构建：运行时阶段
FROM scratch

# 元数据标签
ARG APP_NAME
ARG APP_DESCRIPTION
ARG APP_SOURCE
ARG APP_AUTHOR
ARG APP_VENDOR
ARG APP_LICENSE
ARG APP_DOCS
LABEL org.opencontainers.image.title="${APP_NAME}" \
      org.opencontainers.image.description="${APP_DESCRIPTION}" \
      org.opencontainers.image.source="${APP_SOURCE}" \
      org.opencontainers.image.authors="${APP_AUTHOR}" \
      org.opencontainers.image.vendor="${APP_VENDOR}" \
      org.opencontainers.image.license="${APP_LICENSE}" \
      org.opencontainers.image.documentation="${APP_DOCS}" \
      org.opencontainers.image.created="${BUILD_TIME}" \
      org.opencontainers.image.version="${APP_VERSION}"

WORKDIR /app
# 复制证书和二进制文件
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /output/app /app
COPY templates /templates
COPY static /static

# 设置入口点
ENTRYPOINT ["/app"]