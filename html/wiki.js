function decodeEntities(encodedString) {
  var textArea = document.createElement('textarea');
  textArea.innerHTML = encodedString;
  return textArea.value;
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
          fleqn: true,
          output: 'mathml'
        });
      } catch (e) {
        console.error(e);
      }
    } else {
      try {
        katex.render(decodedMath, x, { output: 'mathml' });
      } catch (e) {
        katex.render(decodedMath, x, {
          displayMode: true,
          fleqn: true,
          output: 'mathml'
        });
      }
    }
    if (x.children) {
      x.parentNode.replaceChild(x.children[0], x);
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
