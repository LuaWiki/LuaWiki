const refMap = {};
let refCounter = 0;
const refList = [];

function buildRef() {
  var $refs = $('references');

  $('ref').each((_, x) => {
    let $x = $(x);
    let name = $x.attr('name');
    let anchor = 'cite-note-error';
    if (name) {
      if (refMap[name]) {
        x.outerHTML = `<sup>[${refMap[name]}]</sup>`;
        return;
      }
      refCounter++;
      anchor = `cite-note-${name}-${refCounter}`;
      refMap[name] = `<a href="#${anchor}">${refCounter}</a>`;
    } else {
      refCounter++;
      anchor = `cite-note-${refCounter}`;
    }
    $(x).before(`<sup>[<a href="#${anchor}">${refCounter}</a>]</sup>`);
    $(x).attr('id', anchor).appendTo($refs);
  })
}

$(document).ready(function(){
  buildRef();
});
