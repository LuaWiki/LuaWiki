package.path = "../modules/?.lua;" .. package.path;
local inspect = require('inspect')
local preprocessor = require('preprocessor')

preprocessor.process([[
测试模板专用页面

{{Cite web|title=河南省焦作市发布暴雨黄色预警_国家应急广播网|url=http://www.cneb.gov.cn/2021/07/21/ARTI1626824519336667.shtml|accessdate=2021-07-21|work=www.cneb.gov.cn|archive-date=2021-07-21|archive-url=https://web.archive.org/web/20210721065022/http://www.cneb.gov.cn/2021/07/21/ARTI1626824519336667.shtml|dead-url=no}}

{{cite web|author1=界面新闻 |title=河南：19个国家级气象站日降水量突破建站以来历史日极值 |url=https://news.sina.com.cn/c/2021-07-21/doc-ikqciyzk6825037.shtml |website=新浪}}

]], 'test')