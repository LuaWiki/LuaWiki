@alias{
  accessdate = access_date
}
@join(@array(
  @citation:authors($_all),
  {[$url @or(@and($title, @utils:escape_bracket($title)),
    @utils:escape_bracket($[script-title]))]},
  @or($website, $work),
  $date,
  @and($accessdate, {[$accessdate]})
), '. ')