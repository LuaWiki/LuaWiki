const refMap = {};
let refCounter = 0;
const refList = [];

function buildRef() {
  var $refs = $('references');
  $refs.parent().addClass('mw-references-columns');

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

function buildMath() {
  $('math,chem').each((_, x) => {
    let decodedMath = x.textContent;
    if (x.nodeName === 'CHEM') {
      decodedMath = '\\ce{' + decodedMath + '}';
    }
    if (x.parentElement.children.length === 1) {
      katex.render(decodedMath, x, {
        displayMode: true,
        fleqn: true
      });
    } else {
      try {
        katex.render(decodedMath, x);
      } catch (e) {
        katex.render(decodedMath, x, {
          displayMode: true,
          fleqn: true
        });
      }
    }
  })
}

$(document).ready(function(){
  buildRef();
  buildMath();
});
