@alias{
  url = 1 | site
  title = 2
}
@and(not $title and not $np, {（})
  [https://web.archive.org/web/@or($date, {*})/$url 
    @or($title, {页面存档备份})]，存于[[互联网档案馆]]
@and(not $title and not $np, {）})