@alias{
  title = script-title
  accessdate = access_date
}
@and($ref == 'harv', {<cite id="@citation:harv_id($_all)">})
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
@and($ref == 'harv', {</cite>})