-- global shared dict
local config = ngx.shared.nla_config

local _M = {}

_M.CAPTCHA_VALIDATE_PAGE = config:get("captcha_validate_page")
_M.CAPTCHA_VALIDATE_API = config:get("captcha_validate_api")
_M.CAPTCHA_COOKIE_NAME = config:get("captcha_cookie_name")

_M.challenge_code_tmpl = [[
<html>
<head>
    <script type="text/javascript">
    function reload() {
        var img = document.getElementById('captcha-img');
        img.src = "http://www.opencaptcha.com/img/%s.jpgx?r=" + Math.random();
    }
    window.onload = reload;
    </script>
</head>
<body>
    <img onclick="reload()" id="captcha-img" />
    <form action="%s" method="GET">
        Please input the verification code to continue:<br />
        <input type="text" name="code" />
        <input type="submit" value="Submit" />
    </form>
</body>
]]

function _M.challenge(captcha_user_id)
    -- set origin URL to cookie
    ngx.header["Set-Cookie"] = _M.CAPTCHA_COOKIE_NAME .. "=" .. ngx.var.request_uri
    local challenge_code = string.format(_M.challenge_code_tmpl,
                                         captcha_user_id,
                                         _M.CAPTCHA_VALIDATE_PAGE)
    ngx.say(challenge_code)
end

function _M.validate(captcha_user_id)
    local uri_args = ngx.req.get_uri_args()
    if not uri_args["code"] then
        return false
    end
    local args = {img = captcha_user_id, ans = uri_args["code"]}
    local res = ngx.location.capture(_M.CAPTCHA_VALIDATE_API, {args = args})
    return (res.body == "pass")
end

return _M
