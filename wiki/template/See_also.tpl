@hatnote{
  参见：
  @or($text, @join_last(
    @map($_num, function(x) return '[[' .. x .. ']]' end),
    {、}, {和})
  )
}