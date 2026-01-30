package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"helloworld/handlers"
)

func main() {
	// 设置端口为80（需要管理员权限）
	port := "80"
	
	// 检查是否以root权限运行（Linux/Mac需要监听80端口）
	if os.Geteuid() != 0 && port == "80" {
		fmt.Println("警告: 监听80端口需要管理员权限")
		fmt.Println("在Linux/Mac上使用: sudo ./hello-world")
		fmt.Println("在Windows上以管理员身份运行")
		fmt.Println("或者将端口改为8080等非特权端口")
		return
	}

	// 创建路由器
	router := handlers.SetupRoutes()

	// 启动服务器
	fmt.Printf("服务器启动在 http://localhost:%s\n", port)
	fmt.Println("按 Ctrl+C 停止服务器")
	
	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatal("服务器启动失败: ", err)
	}
}