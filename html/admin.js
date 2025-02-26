// html/admin.js
class AdminSystem {
    constructor() {
        this.authToken = null;
        this.initAuth();
    }

    initAuth() {
        // 自动处理Basic认证
        const credentials = btoa('admin:admin123');
        fetch('/api/counter', { 
            headers: { 'Authorization': `Basic ${credentials}` }
        }).then(res => {
            this.authToken = res.headers.get('X-Auth-Token');
        });
    }

    async fetchWithAuth(url, options = {}) {
        return fetch(url, {
            ...options,
            headers: {
                ...options.headers,
                'X-Auth-Token': this.authToken
            }
        });
    }

    async updateStatus() {
        try {
            const res = await this.fetchWithAuth('/api/counter');
            const data = await res.json();
            
            // 更新状态显示
            document.getElementById('current-mode').textContent = 
                data.period_duration === 86400 ? '🌞自然日' : '⚙️自定义';
            
            document.getElementById('current-duration').textContent = 
                this.formatDuration(data.period_duration);
                
            const nextReset = new Date(
                Date.parse(data.period_start) + data.period_duration*1000
            );
            document.getElementById('next-reset').textContent = 
                nextReset.toLocaleString();
                
            this.loadAuditLog();
        } catch (err) {
            console.error('状态更新失败:', err);
        }
    }

    formatDuration(sec) {
        if(sec === 86400) return '24小时';
        const h = Math.floor(sec/3600), m = Math.floor((sec%3600)/60), s = sec%60;
        return `${h>0?h+'小时':''}${m>0?m+'分':''}${s}秒`;
    }

    async submitConfig(e) {
        e.preventDefault();
        const duration = document.getElementById('customSec').value || 86400;
        const persist = document.getElementById('persistSec').value || 0;

        try {
            const res = await this.fetchWithAuth('/api/config', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ duration, persist })
            });
            
            if(!res.ok) throw await res.text();
            this.logAction('周期设置', `时长:${duration}秒 持续:${persist}`);
            this.updateStatus();
            
        } catch (err) {
            this.logAction('错误', err, false);
        }
    }

    async loadAuditLog() {
        const res = await this.fetchWithAuth('/api/logs');
        const logs = await res.json();
        const tbody = document.querySelector('#auditLog tbody');
        tbody.innerHTML = logs.map(log => `
            <tr class="${log.success?'success':'error'}">
                <td>${new Date(log.action_time).toLocaleString()}</td>
                <td>${log.action_type}</td>
                <td>${log.parameters}</td>
                <td>${log.success?'✅成功':'❌失败'}</td>
            </tr>
        `).join('');
    }

    logAction(type, params, success=true) {
        this.fetchWithAuth('/api/log', {
            method: 'POST',
            body: JSON.stringify({ type, params, success })
        });
    }
}

// 初始化系统
const adminSystem = new AdminSystem();
document.getElementById('configForm').addEventListener('submit', e => adminSystem.submitConfig(e));
setInterval(() => adminSystem.updateStatus(), 5000);
