let hasTriggered = false;

async function updateCounter() {
    try {
        const res = await fetch('/api/counter');
        const data = await res.json();
        
        document.getElementById('counter').textContent = 
            `周期跨越次数：${data.count}`;
            
        updateCountdown(data);
    } catch (err) {
        console.error('更新失败:', err);
    }
}

function updateCountdown(data) {
    const now = Date.now();
    const cycleEnd = Date.parse(data.period_start) + data.period_duration * 1000;
    let diff = cycleEnd - now;
    
    if (diff < 0) diff = 0;

    const hours = String(Math.floor(diff / 3.6e6)).padStart(2, '0');
    const minutes = String(Math.floor((diff % 3.6e6) / 6e4)).padStart(2, '0');
    const seconds = String(Math.floor((diff % 6e4) / 1e3)).padStart(2, '0');

    document.getElementById('countdown').textContent = `${hours}:${minutes}:${seconds}`;

    if (diff < 1000 && !hasTriggered) {
        hasTriggered = true;
        fetch('/api/increment', { method: 'POST' })
            .then(updateCounter)
            .finally(() => hasTriggered = false);
    }

    requestAnimationFrame(() => updateCountdown(data));
}

// 初始化
updateCounter();
setInterval(updateCounter, 30000);
