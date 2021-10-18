@alias{
  accessdate = access_date
}
@join(@arg_table(
  @or($author, $author1),
  @or(@and($title, @utils:escape_bracket($title)),
    @utils:escape_bracket($[script-title])),
  @or($website, $work),
  $date,
  $pages,
  @and($accessdate, {[$accessdate]})
), '. ')