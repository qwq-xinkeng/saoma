local sqlite3 = require "resty.sqlite3"
local cjson = require "cjson"

local _M = {}

function _M.update()
    ngx.req.read_body()
    local args = cjson.decode(ngx.req.get_body_data())
    
    local db = sqlite3:new()
    local ok, err = db:open("counter.db")
    if not ok then return error_response(500, err) end

    local updates = {
        "period_duration = "..tonumber(args.duration),
        "period_start = datetime('now','localtime')"
    }

    local sql = "UPDATE counters SET "..table.concat(updates, ", ").." WHERE id = (SELECT MAX(id) FROM counters)"
    local res = db:exec(sql)
    
    log_action("UPDATE_CONFIG", cjson.encode(args), res == sqlite3.OK)
    
    if res == sqlite3.OK then
        ngx.say(cjson.encode({status="updated"}))
    else
        error_response(500, db:errmsg())
    end
    
    db:close()
end

function _M.get_logs()
    local db = sqlite3:new()
    db:open("counter.db")
    
    local logs = {}
    for row in db:nrows("SELECT * FROM admin_logs ORDER BY id DESC LIMIT 50") do
        table.insert(logs, row)
    end
    
    ngx.say(cjson.encode(logs))
    db:close()
end

local function log_action(action, params, success)
    local db = sqlite3:new()
    db:open("counter.db")
    db:exec("INSERT INTO admin_logs (action_type, parameters, success) VALUES (?, ?, ?)", 
           {action, params, success and 1 or 0})
    db:close()
end

return _M
