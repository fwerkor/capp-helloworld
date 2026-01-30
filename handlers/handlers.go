package handlers

import (
	"html/template"
	"net/http"
	"path/filepath"
	"time"
	
	"github.com/gorilla/mux"
)

// 页面数据
type PageData struct {
	Title      string
	Message    string
	Time       string
	VisitorIP  string
	Background string
}

// SetupRoutes 设置路由
func SetupRoutes() *mux.Router {
	router := mux.NewRouter()
	
	// 静态文件服务
	router.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	
	// 主页路由
	router.HandleFunc("/", homeHandler)
	router.HandleFunc("/api/hello", apiHandler)
	
	return router
}

// homeHandler 处理主页请求
func homeHandler(w http.ResponseWriter, r *http.Request) {
	// 获取客户端IP
	ip := r.RemoteAddr
	if forwarded := r.Header.Get("X-Forwarded-For"); forwarded != "" {
		ip = forwarded
	}
	
	// 准备页面数据
	data := PageData{
		Title:      "Go Hello World",
		Message:    "欢迎来到Go语言的美丽世界！",
		Time:       time.Now().Format("2006-01-02 15:04:05"),
		VisitorIP:  ip,
		Background: getRandomBackground(),
	}
	
	// 解析模板
	tmpl, err := template.ParseFiles("templates/index.html")
	if err != nil {
		http.Error(w, "模板解析错误: "+err.Error(), http.StatusInternalServerError)
		return
	}
	
	// 渲染模板
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	err = tmpl.Execute(w, data)
	if err != nil {
		http.Error(w, "模板渲染错误: "+err.Error(), http.StatusInternalServerError)
	}
}

// apiHandler 处理API请求
func apiHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"message": "Hello from Go API!", "status": "success", "timestamp": "` + time.Now().Format(time.RFC3339) + `"}`))
}

// getRandomBackground 返回随机背景颜色
func getRandomBackground() string {
	colors := []string{
		"linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
		"linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
		"linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
		"linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
		"linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
	}
	
	// 根据当前分钟数选择颜色
	return colors[time.Now().Minute()%len(colors)]
}