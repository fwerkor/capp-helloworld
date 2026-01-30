# 应用信息
APP_NAME = helloworld #应用唯一名称（必填）
APP_VERSION = v0.1.0 #应用版本
APP_NICKNAME = Hello World! #应用显示名称
APP_DESCRIPTION = A sample CapOS APP #应用简要介绍
APP_SOURCE = https://github.com/fwerkor/capp-helloworld #应用源码地址
APP_AUTHOR = Castronaut <caoyuhang@fwerkor.com> #应用作者
APP_VENDOR = FWERKOR #应用运营者
APP_LICENSE = MIT License #应用许可证
APP_DOCS = https://github.com/fwerkor/capp-helloworld #应用文档


# 应用配置
DEPENDS_OPKG = capbox #对opkg软件包的依赖
DEPENDS_CAPP =  #对其它APP的依赖

PORT_USE = 80 #web服务http端口，详见：https://blog.fwerkor.com/archives/1116
PORT_USE_HTTPS =  #web服务https端口，填写后将默认取代PORT_USE
PORT_USE_HTTPS_SC =  #是否跳过https服务的证书检查
PORT_SET =  #web管理http端口
PORT_SET_HTTPS =  #web管理https端口，填写后将默认取代PORT_SET
PORT_SET_HTTPS_SC =  #是否跳过https管理的证书检查

CMD_EXE =  #容器启动CMD，留空则使用镜像默认
CMD_ETP =  #用户访问终端时调用的程序，如/bin/bash

NET_HOST =  #是否接入host网络
NET_PUBLISH =  #额外端口映射需求，应尽量避免使用

VOL_DATA =  #容器内持久化数据的存储路径，如/app/data
TMPFS =  #容器挂载临时文件系统，如/tmp:size=100m
VOL_FROM =  #从其它容器挂载卷
VOL_EMNT =  #额外挂载需求，如/etc/config:/app/sysconf:rw

DB_MYSQL =  #是否需要系统提供一个可访问的MySQL数据库，详见：https://blog.fwerkor.com/archives/1113

PRIVILEGED =  #是否启用特权模式，启用后将覆盖其它关于权限的选项
CAPABILITY = NET_BIND_SERVICE #容器capabilities，默认无任何权限
NEWPRIVS =  #是否允许容器进程提权，默认禁止提权

SYSTEMD =  #是否为容器启用systemd，默认不启用

MEM_RESV =  #预留内存容量
SHM_SIZE =  #/dev/shm大小，如256m

ENV =  #附加环境变量配置

DEVICE =  #附加设备挂载，如/dev/ttyUSB0:/dev/ttyUSB0

HEALTH_CMD = curl -f http://localhost/ #健康检查命令
HEALTH_INTERVAL = 30s #健康检查间隔
HEALTH_RETRIES = 3 #健康检查重试次数
HEALTH_STARTPERIOD = 5s #健康检查启动等待时间
HEALTH_TIMEOUT = 10s #健康检查超时时间
HEALTH_NO =  #是否禁用健康检查


# 构建配置
ARCHITECTURES = amd64 arm64 #应用支持的硬件架构
PRIVATEKEY =  #私钥文件路径，用于校验开发者身份，详见https://blog.fwerkor.com/archives/1119
FILES_EXT = icon.jpg #额外打包加入安装包中的文件