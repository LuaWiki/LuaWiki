@alias{
  title = script-title
  accessdate = access_date | access-date
}
@join(@array(
  @citation:authors($_all),
  @or(
    @and($title, 
      @or(@and($url, {[$url @utils:escape_bracket($title)]}), $title)
    ), 
    $url
  ),
  @or($website, $work),
  $date,
  @and($accessdate, {[$accessdate]})
), '. ')