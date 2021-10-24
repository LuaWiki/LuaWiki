<div class="legend">
  <span class="legend-color" style="
    @or(@and($border, {border: $border;}),
      @and($outline, {border: 1px solid $outline;}))
    @and($1, {background-color: $1;})
    @and($text, {
      @and($color, {color: $color;})
      @and($size, {font-size: $size;})
    })
  ">@or($text, {&nbsp;})</span> $2
</div>