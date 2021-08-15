@hatnote{
  主条目：
  @or($text, @join_last(
    @map($_num, function(x) return '[[' .. x .. ']]' end),
    {、}, {和})
  )
}