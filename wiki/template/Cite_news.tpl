@alias{
  accessdate = access_date
}
@join(@arg_table(
  $author1,
  {[$url @utils:escape_bracket($title)]},
  @or($website, $work),
  $date,
  @and($accessdate, {[$accessdate]})
), '. ')