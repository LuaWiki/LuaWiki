# LuaWiki
MediaWiki parser in Lua

## Requirements
- [luapower](https://luapower.com) - all in one / install following packages
  - cjson lpeg luajit luapower-repos nginx openssl pcre resty.http resty-core resty-lrucache zlib
- [re.lua](https://github.com/roberto-ieru/LPeg/blob/master/re.lua) - lastest version from Roberto Ierusalimschy's GitHub repo

## Goal
Become an alternative to MediaWiki, a lighter implementation. 
- [ ] an LPeg based MediaWiki parser, from MW to HTML
- [ ] re-implement key templates in Lua, and migrate Wikipedia's Lua modules
- [ ] incorporate MariaDB as a database, design basic tables for use
- [ ] editing API and web editor
- [ ] (maybe) sync with Wikipedia, and allow Wikimedia OAuth login, and save to Wikipedia
