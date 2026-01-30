document.addEventListener('DOMContentLoaded', function() {
    // 元素引用
    const changeColorBtn = document.getElementById('changeColorBtn');
    const apiTestBtn = document.getElementById('apiTestBtn');
    const timeUpdateBtn = document.getElementById('timeUpdateBtn');
    const apiResult = document.getElementById('apiResult');
    const background = document.querySelector('.background');
    const timeElement = document.querySelector('.detail-item:nth-child(1) strong');
    
    // 背景颜色数组
    const backgrounds = [
        "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
        "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
        "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
        "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
        "linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
        "linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)",
        "linear-gradient(135deg, #d299c2 0%, #fef9d7 100%)",
        "linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)"
    ];
    
    // 当前背景索引
    let currentBgIndex = 0;
    
    // 切换背景颜色
    changeColorBtn.addEventListener('click', function() {
        currentBgIndex = (currentBgIndex + 1) % backgrounds.length;
        background.style.background = backgrounds[currentBgIndex];
        
        // 添加动画效果
        background.style.opacity = '0.8';
        setTimeout(() => {
            background.style.opacity = '1';
        }, 300);
    });
    
    // 测试API
    apiTestBtn.addEventListener('click', function() {
        apiTestBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 请求中...';
        apiTestBtn.disabled = true;
        
        fetch('/api/hello')
            .then(response => response.json())
            .then(data => {
                apiResult.textContent = JSON.stringify(data, null, 2);
                apiResult.style.display = 'block';
                apiTestBtn.innerHTML = '<i class="fas fa-cloud"></i> 测试API';
                apiTestBtn.disabled = false;
                
                // 3秒后隐藏结果
                setTimeout(() => {
                    apiResult.style.display = 'none';
                }, 3000);
            })
            .catch(error => {
                apiResult.textContent = 'API请求错误: ' + error;
                apiResult.style.display = 'block';
                apiTestBtn.innerHTML = '<i class="fas fa-cloud"></i> 测试API';
                apiTestBtn.disabled = false;
            });
    });
    
    // 更新时间
    timeUpdateBtn.addEventListener('click', function() {
        const now = new Date();
        const formattedTime = now.getFullYear() + '-' + 
                             String(now.getMonth() + 1).padStart(2, '0') + '-' + 
                             String(now.getDate()).padStart(2, '0') + ' ' + 
                             String(now.getHours()).padStart(2, '0') + ':' + 
                             String(now.getMinutes()).padStart(2, '0') + ':' + 
                             String(now.getSeconds()).padStart(2, '0');
        
        timeElement.textContent = formattedTime;
        
        // 添加视觉反馈
        timeUpdateBtn.innerHTML = '<i class="fas fa-check"></i> 已更新';
        setTimeout(() => {
            timeUpdateBtn.innerHTML = '<i class="fas fa-redo"></i> 更新时间';
        }, 1000);
    });
    
    // 初始加载时显示当前时间
    const now = new Date();
    const formattedTime = now.getFullYear() + '-' + 
                         String(now.getMonth() + 1).padStart(2, '0') + '-' + 
                         String(now.getDate()).padStart(2, '0') + ' ' + 
                         String(now.getHours()).padStart(2, '0') + ':' + 
                         String(now.getMinutes()).padStart(2, '0') + ':' + 
                         String(now.getSeconds()).padStart(2, '0');
    timeElement.textContent = formattedTime;
});