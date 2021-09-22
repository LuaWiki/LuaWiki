const refMap = {};
let refCounter = 0;
const refList = [];

function decodeEntities(encodedString) {
  var textArea = document.createElement('textarea');
  textArea.innerHTML = encodedString;
  return textArea.value;
}

function buildRef() {
  var $refs = $('references');
  $refs.parent().addClass('mw-references-columns');
  
  let refMap = {}
  $refs.each((_, x) => {
    let $x = $(x);
    let group = $x.attr('group');
    let anonAppeared = false
    if (!group && !anonAppeared) {
      refMap[''] = $x;
      anonAppeared = true;
    } else if (!refMap[group]) {
      refMap[group] = $x;
    }
  })
  
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
    $x.before(`<sup>[<a href="#${anchor}">${refCounter}</a>]</sup>`);
    $x.attr('id', anchor);
    
    let group = $x.attr('group') || '';
    if (refMap[group]) $x.appendTo(refMap[group]);
  });
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
  buildRef();
  buildMath();
  buildHighlight();
});
