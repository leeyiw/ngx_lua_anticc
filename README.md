# ngx_lua_anticc
**ngx_lua_anticc** is a CC(ChallengeCollapsar) attack mitigation tool for Nginx. CC attack (i.e. HTTP request flood) is kind of layer 7 DDoS attack. ngx_lua_anticc is an extension of Nginx based on [ngx_lua](https://github.com/openresty/lua-nginx-module). With it, you can easily add CC attack protection for your web server.

# Download
Current release: [ngx_lua_anticc-0.1.0.tar.gz](https://github.com/leeyiw/ngx_lua_anticc/archive/v0.1.0.tar.gz).

# Configure && Install
## 1. Prepare your nginx
To use ngx_lua_anticc, you must recompile your nginx with ngx_lua support, see the installation document over [HERE](http://wiki.nginx.org/HttpLuaModule#Installation). ngx_lua depends on LuaJIT (recommended) or Lua, please make sure you have installed LuaJIT/Lua before any further configuration.

## 2. Deploy ngx_lua_anticc with your nginx
1. Uncompress the tarball to the same directory with the `nginx.conf` file.

2. Edit your `nginx.conf`, add `include ngx_lua_anticc/nla.conf;` into the *http* section.

3. Add `include ngx_lua_anticc/nla_captcha.conf;` into the *server* section.

## 3. Configure ngx_lua_anticc (IMPORTANT)
1. Edit the config file `ngx_lua_anticc/nla.conf`. You **MUST** change the value of `cookie_key` to your own secret value. Otherwise, the attackers will generate verification cookie (by default `cookie_key` in source code) to bypass the protection mechanism designed by ngx_lua_anticc. Example:
  ```
  config:add("cookie_key", "f136f204e0586f02")
  ```

2. Add trusted IP into whitelist:
  ```
  whitelist:add("127.0.0.1", true)
  ```
   The boolean value means if the whitelist entry is enabled (true) or not.

## 4. Restart nginx
After you restart nginx, the Anti-CC protection is automatically enabled. Enjoy your web service without CC attacks!
