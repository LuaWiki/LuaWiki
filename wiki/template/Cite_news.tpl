@alias{
  accessdate = access_date
}
@join(@arg_table(
  $author1,
  {[$url @or(@and($title, @utils:escape_bracket($title)),
    @utils:escape_bracket($[script-title]))]},
  @or($website, $work),
  $date,
  @and($accessdate, {[$accessdate]})
), '. ')