local sqlite3 = require "resty.sqlite3"
local cjson = require "cjson"

local _M = {}

function _M.get()
    local db = sqlite3:new()
    local ok, err = db:open("counter.db")
    if not ok then return error_response(500, err) end

    local stmt = db:prepare("SELECT * FROM counters ORDER BY id DESC LIMIT 1")
    local row = stmt:step()
    
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode({
        count = row[2],
        last_reset = row[3],
        period_start = row[4],
        period_duration = row[5]
    }))
    
    stmt:close()
    db:close()
end

local function error_response(code, msg)
    ngx.status = code
    ngx.say(cjson.encode({error=msg}))
    ngx.exit(code)
end

return _M
