@alias{
  title = script-title
  accessdate = access_date
}
@join(@array(
  @citation:authors($_all),
  @join(@array(
    @or(@and($url, {[$url @utils:escape_bracket($title)]}), $title),
    $edition
  ), ' '),
  @join(@array(
    $location, $publisher
  ), ': '),
  @join(@array(
    @or($date, $year),
    @and($origyear, {[$origyear]})
  ), ' '),
  @and(@and($url, $accessdate), {[$accessdate]}),
  @and($isbn, {ISBN: $isbn}),
  @and($doi, {[https://dx.doi.org/$doi doi:$doi]})
), '. ')