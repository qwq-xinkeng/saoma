local sqlite3 = require "resty.sqlite3"
local cjson = require "cjson"

local _M = {}

function _M.post()
    local db = sqlite3:new()
    local ok, err = db:open("counter.db")
    if not ok then return error_response(500, err) end

    local res = db:exec([[
        UPDATE counters SET 
            count = count + 1, 
            last_reset = CURRENT_TIMESTAMP 
        WHERE id = (SELECT MAX(id) FROM counters)
    ]])

    if res == sqlite3.OK then
        ngx.say(cjson.encode({status="success"}))
    else
        error_response(500, db:errmsg())
    end
    
    db:close()
end

return _M
