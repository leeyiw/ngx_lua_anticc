local _M = {}

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

function _M.challenge(captcha_validate_page, captcha_user_id)
    -- use JS set cookie to challenge
    local challenge_code = string.format(_M.challenge_code_tmpl,
                                         captcha_user_id,
                                         captcha_validate_page)
    ngx.say(challenge_code)
end

return _M
