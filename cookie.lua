local _M = {}

_M.challenge_code_tmpl = [[
<html>
<head>
    <script type="text/javascript">
    if (document.cookie) {
        document.cookie += '; ';
    }
    document.cookie += '%s=%s';
    window.location.reload();
    </script>
</head>
<body>
</body>
]]

function _M.get()
    local headers = ngx.req.get_headers();
    local ret = {}
    if not headers["Cookie"] then
        return ret
    end
    for k, v in string.gmatch(headers["Cookie"], "([^=]+)=([^;]+);?%s*") do
        ret[k] = v
    end
    return ret
end

function _M.challenge(cookie_name, cookie_value)
    -- if static resource is requested, use Set-Cookie and 302 to challenge
    if ngx.re.find(ngx.var.uri, "\\.(bmp|css|gif|jpe?g|js|png)$", "ioj") then
        ngx.header["Set-Cookie"] = cookie_name .. "=" .. cookie_value
        ngx.redirect(ngx.var.request_uri)
        return
    end

    -- use JS set cookie to challenge
    local challenge_code = string.format(_M.challenge_code_tmpl, cookie_name,
                                         cookie_value)
    ngx.say(challenge_code)
end

return _M
