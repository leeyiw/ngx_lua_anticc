-- global shared dict
local config = ngx.shared.nla_config
local req_count = ngx.shared.nla_req_count;
local captcha_pass_list = ngx.shared.nla_captcha_pass_list

-- config options
local COOKIE_NAME = config:get("cookie_name")
local COOKIE_KEY = config:get("cookie_key")
local CAPTCHA_VALIDATE_PAGE = config:get("captcha_validate_page")
local CAPTCHA_COOKIE_NAME = config:get("captcha_cookie_name")

-- library
local cookie = require("cookie")
local captcha = require("captcha")

local headers = ngx.req.get_headers();
local cookies = cookie.get()
local user_id = ngx.md5(ngx.var.remote_addr .. ngx.var.uri .. COOKIE_KEY)
local captcha_user_id = ngx.md5(ngx.var.remote_addr .. (headers["User-Agent"] or "") .. COOKIE_KEY)

-- if request captcha validate page, then validate captcha code
if ngx.var.uri == CAPTCHA_VALIDATE_PAGE then
    if captcha.validate(captcha_user_id) then
        captcha_pass_list:set(captcha_user_id, true, 3600)
    end
    return ngx.redirect(cookies[CAPTCHA_COOKIE_NAME] or "/")
end

local count, err = req_count:incr(user_id, 1)
if not count then
    req_count:add(user_id, 1, 1)
    return
end

-- identify if request is page or resource
if ngx.re.find(ngx.var.uri, "\\.(bmp|css|gif|ico|jpe?g|js|png)$", "ioj") then
    ngx.ctx.nla_rtype = "resource"
else
    ngx.ctx.nla_rtype = "page"
end

-- if QPS is exceed 5, start cookie challenge
if count > 5 then
    if cookies[COOKIE_NAME] ~= user_id then
        cookie.challenge(COOKIE_NAME, user_id)
        return
    end
end

-- if cookie challenge is passed and QPS is exceed 10, start captcha challenge
if count > 10 then
    if ngx.ctx.nla_rtype ~= "resource" and (not captcha_pass_list:get(captcha_user_id)) then
        captcha.challenge(captcha_user_id)
        return
    end
end
