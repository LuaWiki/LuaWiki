const refMap = {};
const refList = [];

function decodeEntities(encodedString) {
  var textArea = document.createElement('textarea');
  textArea.innerHTML = encodedString;
  return textArea.value;
}

function buildRef() {
  var $refs = $('references');
  $refs.parent().addClass('mw-references-columns');
  
  let groupMap = {}
  $refs.each((_, x) => {
    let $x = $(x);
    let group = $x.attr('group') || '';
    if (!groupMap[group]) {
      groupMap[group] = $x;
    }
  })
  
  function buildRefGroup(g, suffix) {
    let refMap = {}
    let refCounter = 0;
    $('ref' + suffix).each((_, x) => {
      try {
        let $x = $(x);
        let name = $x.attr('name');
        let anchor = 'cite-note-error';
        if (name) {
          if (refMap[name]) {
            anchor = `cite-note-${name}-${refMap[name]}`;
            if (x.childNodes.length) {
              $('#' + anchor).html($x.html());
            }
            x.outerHTML = `<sup>[<a href="#${anchor}">${refMap[name]}</a>]</sup>`;
            return;
          }
          refCounter++;
          anchor = `cite-note-${name}-${refCounter}`;
          refMap[name] = refCounter;
        } else {
          refCounter++;
          anchor = `cite-note-${refCounter}`;
        }
        $x.before(`<sup>[<a href="#${anchor}">${refCounter}</a>]</sup>`);
        $x.attr('id', anchor);

        $x.appendTo(groupMap[g]);
      } catch (e) {
        console.error(e);
      }
    });
  }
  
  for (const g in groupMap) {
    buildRefGroup(g, `[group="${g}"]`);
  }
  buildRefGroup('', `:not([group])`);
}

function buildMath() {
  $('math,chem').each((_, x) => {
    let decodedMath = x.textContent;
    if (x.nodeName === 'CHEM') {
      decodedMath = '\\ce{' + decodedMath + '}';
    }
    if (x.parentElement.childNodes.length === 1) {
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

function buildHighlight() {
  $('syntaxhighlight').each((_, x) => {
    x.className = 'language-' + x.lang + ' hljs';
    x.innerHTML = hljs.highlight(decodeEntities(x.textContent.replace(/^[ \t]*\n/, '')),
      {language: x.lang}).value;
  })
}

$(document).ready(function(){
  document.body.innerHTML = doMwConvert(document.body.innerHTML);
  buildRef();
  buildMath();
  buildHighlight();
});
