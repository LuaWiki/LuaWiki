const refMap = {};
const refList = [];

function decodeEntities(encodedString) {
  var textArea = document.createElement('textarea');
  textArea.innerHTML = encodedString;
  return textArea.value;
}

function buildRef() {
  var $refs = $('references');
  var $hidrefs = $('.hidden');
  if (!$hidrefs.length) {
    $('<div class="hidden"></div>').appendTo($refs.parent());
    $hidrefs = $('.hidden');
  }
  $refs.children().appendTo($hidrefs);
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
        let name = $x.attr('name')
        let anchor = 'cite_note-error';
        if (name) {
          name = name.replace(/ /g, '_');
          if (refMap[name]) {
            anchor = `cite_note-${name}-${refMap[name]}`;
            if (x.childNodes.length) {
              const targetElement = document.getElementById(anchor);
              targetElement.className = '';
              targetElement.innerHTML = decodeEntities(x.textContent);
            }
            x.outerHTML = `<sup>[<a href="#${anchor}">${g ? g + ' ' : ''}${refMap[name]}</a>]</sup>`;
            return;
          }
          refCounter++;
          anchor = `cite_note-${name}-${refCounter}`;
          refMap[name] = refCounter;
        } else {
          refCounter++;
          anchor = `cite_note-${g}${refCounter}`;
        }
        $x.before(`<sup>[<a href="#${anchor}">${g ? g + ' ' : ''}${refCounter}</a>]</sup>`);
        $x.attr('id', anchor);
        if (x.textContent) {
          $x.html(decodeEntities(x.textContent));
        } else {
          $x.addClass('cite_note-error');
          $x.html(`引用错误：没有为名为<code>${name}</code>的参考文献提供内容`)
        }

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
      try {
        katex.render(decodedMath, x, {
          displayMode: true,
          fleqn: true
        });
      } catch (e) {
        console.error(e);
      }
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
    try {
      x.innerHTML = hljs.highlight(decodeEntities(x.textContent.replace(/^[ \t]*\n/, '')),
        {language: x.lang}).value;
    } catch (e) {
      x.innerHTML = x.textContent.replace(/^[ \t]*\n/, '');
      console.error(e);
    }
  })
}
