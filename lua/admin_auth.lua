local resty_hmac = require "resty.hmac"

local _M = {}
local secret = "b3Blbl9yZXN0eV9zZWNyZXRfa2V5"

function _M.init()
    ngx.shared.admin_sessions:set("admin", ngx.md5("admin123"))
end

function _M.check()
    local auth = ngx.var.http_Authorization
    if not auth then
        ngx.header["WWW-Authenticate"] = 'Basic realm="Admin Area"'
        ngx.exit(401)
    end

    local cred = ngx.decode_base64(auth:sub(7))
    local user, pass = cred:match("^(.*):(.*)$")
    if ngx.md5(pass) ~= ngx.shared.admin_sessions:get(user) then
        ngx.exit(403)
    end

    local hmac_inst = resty_hmac:new(secret, resty_hmac.ALGOS.SHA256)
    ngx.header["X-Auth-Token"] = hmac_inst:final(os.time()..user)
end

function _M.verify_token()
    local hmac_inst = resty_hmac:new(secret, resty_hmac.ALGOS.SHA256)
    local expect = hmac_inst:final(os.time().."admin")
    
    if ngx.req.get_headers()["X-Auth-Token"] ~= expect then
        ngx.exit(403)
    end
end

return _M
