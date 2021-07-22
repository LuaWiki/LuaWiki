@join(@arg_table(
  $author1,
  {[$url $title]},
  @or($website, $work),
  $date,
  @and($accessdate, {[$accessdate]})
), '. ')