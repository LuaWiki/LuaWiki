package.path = "../modules/?.lua;" .. package.path;
local inspect = require('inspect')
local preprocessor = require('preprocessor').new()

print(

preprocessor:process([==[
{{cite news |author1=河南日报 |title=郑州气象局：郑州特大暴雨千年一遇，三天下了以往一年的量 |url=https://www.thepaper.cn/newsDetail_forward_13673710 |accessdate=2021-07-21 |publisher=澎湃 |date=2021-07-20 |archive-date=2021-07-21 |archive-url=https://web.archive.org/web/20210721125656/https://www.thepaper.cn/newsDetail_forward_13673710 |dead-url=no }}

]==], 'test')

)