@alias{
  accessdate = access_date
}
@join(@array(
  @or($author, $author1),
  @or(@and($title, @utils:escape_bracket($title)),
    @utils:escape_bracket($[script-title])),
  @or($website, $work),
  $date,
  $pages,
  @and($accessdate, {[$accessdate]})
), '. ')