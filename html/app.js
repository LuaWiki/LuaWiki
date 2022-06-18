/**
 * MAIN APP JAVASCRIPT
 */

 
let outputDiv = null;
let hashStore = [];
let hashIndex = 0;
let $content = $('#content');
let oldestState = { content: $content.html(), title: document.title, type: 'main' };
let sectionObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (entry.intersectionRatio > 0) {
        $(`aside li a[href="#${id}"]`).parent().addClass('active');
      } else {
        $(`aside li a[href="#${id}"]`).parent().removeClass('active');
      }
    });
  });

$(document).ready(mainContentLoaded);

function mainContentLoaded() {
  outputDiv = document.getElementById('parser-output');
  hashStore = [ { hash: '' } ];
  hashIndex = 0;
  
  const tpl = document.createElement('div');
  tpl.innerHTML = doMwConvert(outputDiv.innerHTML);
  const tpl2 = document.createElement('div');
  tpl2.appendChild(tpl.childNodes[0]);
  let headerCounter = 0;
  let h2Sec = document.createElement('section');
  let h3Sec = null;
  let length = tpl.childNodes.length;
  while (length--) {
    let x = tpl.childNodes[0];
    if (x.nodeName === 'H2') {
      if (h3Sec) {
        h2Sec.appendChild(h3Sec);
        h3Sec = null;
      }
      tpl2.appendChild(h2Sec);
      h2Sec = document.createElement('section');
      h2Sec.id = 'toc' + (++headerCounter)
      h2Sec.appendChild(x);
    } else if (x.nodeName === 'H3') {
      if (h3Sec) {
        h2Sec.appendChild(h3Sec);
      }
      h3Sec = document.createElement('section');
      h3Sec.id = 'toc' + (++headerCounter)
      h3Sec.appendChild(x);
    } else {
      if (h3Sec) {
        h3Sec.appendChild(x);
      } else {
        h2Sec.appendChild(x);
      }
    }
  }
  tpl2.appendChild(h2Sec);
  outputDiv.innerHTML = tpl2.innerHTML;
  
  buildToc();
  buildRef();
  buildMath();
  buildHighlight();
}

function buildToc() {
  $('section[id]').each((_, section) => {
    sectionObserver.observe(section);
  });
  
  const tocArr = [];
  $('h2, h3').each((i, x) => {
    if (x.nodeName === 'H2') {
      tocArr.push({
        name: x.innerText,
        link: '#' + x.parentElement.id,
        children: []
      });
    } else {
      tocArr[tocArr.length - 1].children.push({
        name: x.innerText,
        link: '#' + x.parentElement.id
      })
    }
  });
  $('#content > aside').html('<ul>' + tocArr.map(x => {
    let myChildren = x.children.length ? ('<ul>' + x.children.map(y => {
      return `<li><a href="${y.link}">${y.name}</a></li>`;
    }).join('') + '</ul>') : '';
    return `<li><a href="${x.link}">${x.name}</a>
      ${myChildren}
    </li>`
  }).join('') + '</ul>');
}

window.addEventListener('hashchange', function() {
  hashStore[hashIndex].pos = outputDiv.scrollTop;
  if (hashStore[hashIndex - 1] !== undefined && location.hash === hashStore[hashIndex - 1].hash) {
    outputDiv.scrollTop = hashStore[--hashIndex].pos;
  } else if (hashStore[hashIndex + 1] !== undefined && location.hash === hashStore[hashIndex + 1].hash) {
    outputDiv.scrollTop = hashStore[++hashIndex].pos;
  } else {
    hashStore[++hashIndex] = {
      hash: location.hash
    };
  }
}, false);

// NAVIGATION
function routeHandler(route, content, title, type) {
  if (!type) type = 'main';
  sectionObserver.disconnect();
  
  if (type === 'main') {
    $content.addClass('has-toc');
  } else {
    $content.removeClass('has-toc');
  }
  
  $content.html(content);
  $content.find("script").each((_, oldScript) => {
    const newScript = document.createElement("script");
    Array.from(oldScript.attributes)
      .forEach( attr => newScript.setAttribute(attr.name, attr.value) );
    newScript.appendChild(document.createTextNode(oldScript.innerHTML));
    oldScript.parentNode.replaceChild(newScript, oldScript);
  });
  window.history.pushState({ content, title, type }, title, route);
}

window.addEventListener("popstate", function(e) {
  let state = e.state || oldestState
  $('#content').html(state.content);
  if (state.type === 'main') {
    $content.addClass('has-toc');
    mainContentLoaded();
  } else {
    $content.removeClass('has-toc');
  }
});

async function getRemoteHTML(url, route, title, type) {
  let html = await fetch(url).then(res => res.text());
  routeHandler(route, html, title, type);
}
