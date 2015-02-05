-- global shared dict
local config = ngx.shared.nla_config
local req_count = ngx.shared.nla_req_count;
local captcha_pass_list = ngx.shared.nla_captcha_pass_list

-- config options
local COOKIE_NAME = config:get("cookie_name")
local COOKIE_KEY = config:get("cookie_key")
local CAPTCHA_VALIDATE_PAGE = config:get("captcha_validate_page")

-- library
local cookie = require("cookie")
local captcha = require("captcha")

local headers = ngx.req.get_headers();
local cookies = cookie.get()
local user_id = ngx.md5(ngx.var.remote_addr .. ngx.var.uri .. COOKIE_KEY)

local count, err = req_count:incr(user_id, 1)
if not count then
    req_count:add(user_id, 1, 1)
    return
end

if count > 10 then
    -- check if cookie is exists
    if cookies[COOKIE_NAME] ~= user_id then
        cookie.challenge(COOKIE_NAME, user_id)
        return
    end
end

-- if set-cookie challenge is passed and QPS is exceed 50, start captcha challenge
if count > 20 then
    if not headers["User-Agent"] then
        headers["User-Agent"] = "nil"
    end
    local captcha_user_id = ngx.md5(ngx.var.remote_addr .. headers["User-Agent"] .. COOKIE_KEY)
    if not captcha_pass_list:get(captcha_user_id) then
        captcha.challenge(CAPTCHA_VALIDATE_PAGE, captcha_user_id)
        return
    end
end
