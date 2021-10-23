@hatnote{
  更多信息：
  @or($text, @join_last(
    @map($_num, function(x) return '[[' .. x .. ']]' end),
    {、}, {和})
  )
}