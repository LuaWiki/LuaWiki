// The function takes an encoded string as an argument and
// returns a decoded string by creating a temporary text area element and
// setting its inner HTML to the encoded string.
function decodeEntities(encodedString) {
  var textArea = document.createElement('textarea');
  textArea.innerHTML = encodedString;
  return textArea.value;
}

// The function iterates over all the math and chem elements in the document and
// renders them using katex. It also checks if the element is the only child of 
// its parent and sets the displayMode and fleqn options accordingly.
// Finally, it replaces the original element with its rendered child.
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

// The buildHighlight function iterates over all the syntaxhighlight elements in the document and
// sets their class name according to their lang attribute. It also tries to highlight their inner
// HTML using hljs.highlight with their lang attribute as the language option. If it fails,
// it just sets their inner HTML to their text content without highlighting.
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
