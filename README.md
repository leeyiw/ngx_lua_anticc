# ngx_lua_anticc
**ngx_lua_anticc** is a CC(ChallengeCollapsar) attack mitigation tool for Nginx. CC attack (i.e. HTTP request flood) is kind of layer 7 DDoS attack. ngx_lua_anticc is an extension of Nginx based on [ngx_lua](https://github.com/openresty/lua-nginx-module). With it, you can easily add CC attack protection for your web server.

# Download
Current release: [ngx_lua_anticc-0.1.0.tar.gz](https://github.com/leeyiw/ngx_lua_anticc/archive/v0.1.0.tar.gz).

# Install
## 1. Prepare your nginx
To use ngx_lua_anticc, you must recompile your nginx with ngx_lua support, see the installation help at [HERE](http://wiki.nginx.org/HttpLuaModule#Installation).

## 2. Deploy ngx_lua_anticc with your nginx
1. Uncompress the tarball to the same directory with the `nginx.conf` file.

2. Edit your `nginx.conf`, add `include ngx_lua_anticc/nla.conf;` into the *http* section.

3. Add `include ngx_lua_anticc/nla_captcha.conf;` into the *server* section.
