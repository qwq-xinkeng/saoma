local sqlite3 = require "resty.sqlite3"

local _M = {}

function _M.init()
    local db = sqlite3:new()
    local ok, err = db:open("counter.db")
    if not ok then return ngx.log(ngx.ERR, "DB init failed: ", err) end

    db:exec([[
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
    ]])
    db:close()
end

return _M
