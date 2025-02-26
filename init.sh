#!/bin/bash
mkdir -p lua html
sqlite3 counter.db <<EOF
CREATE TABLE IF NOT EXISTS counters (
    id INTEGER PRIMARY KEY,
    count INTEGER DEFAULT 0,
    last_reset TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    period_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    period_duration INTEGER DEFAULT 86400
);
CREATE TABLE IF NOT EXISTS admin_logs (
    id INTEGER PRIMARY KEY,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type TEXT,
    parameters TEXT,
    success BOOLEAN
);
INSERT INTO counters (count) SELECT 0 WHERE NOT EXISTS (SELECT 1 FROM counters);
EOF
htpasswd -bc .htpasswd admin admin123
echo "初始化完成！"
