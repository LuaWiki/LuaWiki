@switch($1,
  @cases({}), @or($blank, $no, {}),
  @cases({¬}), @or($[¬], {}),
  @cases({yes}, {y}, {true}, {t}, {是}, {1}), @or($yes, {yes}),
  @cases({no}, {n}, {false}, {f}, {否}, {0}), @or($no, {}),
  {default}, @or($def, $yes, {yes})
)
