local upload = require "resty.upload"
local cjson = require "cjson"

local chunk_size = 5 -- should be set to 4096 or 8192
                     -- for real-world settings

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(1000) -- 1 sec

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end

    ngx.say("read: ", cjson.encode({typ, res}))

    if typ == "eof" then
        break
    end
end

ngx.say("=======================")
local typ, res, err = form:read()
ngx.say("read: ", cjson.encode({typ, res}))
