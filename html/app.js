/**
 * MAIN APP JAVASCRIPT
 */
 
let outputDiv = null;
let hashStore = [];
let hashIndex = 0;
let $content = $('#content');
let oldestState = { content: $content.html(), title: document.title, type: 'main' };
let lastPath = location.pathname;

let loggedIn = document.cookie.includes('session=');

// data to bind
const appData = {
  showEdit: loggedIn,
  showSubmit: false
};

(function initAppData() {
  let store = {};
  for (let prop in appData) {
    store[prop] = {
      value: appData[prop],
      listeners: []
    };
    Object.defineProperty(appData, prop, {
      get: function() {
        return store[prop].value;
      },
      set: function(value) {
        store[prop].value = value;
        // call listeners
        store[prop].listeners.forEach(x => x(value));
      }
    });
  }
  
  // search for binded props in document
  $('[v-show]').each((_, x) => {
    let prop = x.getAttribute('v-show');
    let showHandler = function(value) {
      if (value) {
        x.style.display = 'block';
      } else {
        x.style.display = 'none';
      }
    }
    showHandler(appData[prop]);
    if (store[prop]) {
      store[prop].listeners.push(showHandler);
    }
  });
})();

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

async function loadArticle(title) {
  let res = await fetch(`/page/html/${title}`).then(res => res.json());
  if (res.code === 0) {
    html = res.result + `<!-- Total parse time: ${res.parse_time}-->`;
    html = `<aside></aside><article id="parser-output">${html}</article>`;
    routeHandler(title, html, decodeURIComponent(title));
    mainContentLoaded();
  }
}

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
  $content.find('a[href^="/wiki/"]').click(async function(event) {
    let newTitle = this.href.match(/\/wiki\/(.*)/) && RegExp.$1;
    loadArticle(newTitle);
  })
  
  buildToc();
  buildRef();
  
  $content.find('a:not(.external)').click(function(event) {
    event.preventDefault();
    let href = this.getAttribute('href');
    if (href[0] === '#') {
      if (href[1] === '/') {
        // i.e. edit? history?
        
      } else {
        let targetPos = document.getElementById(href.substring(1)).offsetTop;
        window.history.pushState({ type: 'hash', pos: targetPos }, '', href);
        outputDiv.scrollTop = targetPos;
      }
    } else {
      // internal links, etc.
    }
  });
  
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

/*
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
*/
function exitedEditor() {
  appData.showEdit = true;
  appData.showSubmit = false;
  window.ace = null;
}

function setContentAndRunScript(content) {
  $content.html(content);
  $content.find("script").each((_, oldScript) => {
    const newScript = document.createElement("script");
    Array.from(oldScript.attributes)
      .forEach( attr => newScript.setAttribute(attr.name, attr.value) );
    newScript.appendChild(document.createTextNode(oldScript.innerHTML));
    oldScript.parentNode.replaceChild(newScript, oldScript);
  });
}

// NAVIGATION
function routeHandler(route, content, title, type) {
  if (!type) type = 'main';
  sectionObserver.disconnect();
  
  if (type === 'main') {
    $content.addClass('has-toc');
    route = '/wiki/' + route;
  } else {
    $content.removeClass('has-toc');
  }
  
  setContentAndRunScript(content);
  window.history.pushState({ content, title, type }, title, route);
  lastPath = location.pathname;
}

window.addEventListener("popstate", function(e) {
  if (e.state && e.state.type === 'hash') {
    outputDiv.scrollTop = e.state.pos;
    return;
  }
  lastPath = location.pathname;
  let state = e.state || oldestState
  setContentAndRunScript(state.content);
  if (state.type === 'main') {
    exitedEditor();
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

function gotoLogin() {
  location.href = '/login.html?returnUrl=' + location.pathname;
}

async function editPage() {
  window.pagename = lastPath.match(/\/wiki\/([^#]+)/) && RegExp.$1;
  if (!pagename) return;
  getRemoteHTML('/editor.html', '#/edit', '编辑', 'tool');
  appData.showEdit = false;
  appData.showSubmit = true;
  let res = await fetch('/page/wikitext/' + pagename).then(res => res.json());
  if (res.code === 0) {
    document.addEventListener('aceInit', () => {
      editor.session.setValue(res.result);
      window.editorChanged = true;
    })
  }
}

async function submitPage() {
  if (!window.editor) return;
  let pagename = lastPath.match(/\/wiki\/([^#]+)/) && RegExp.$1;
  if (!pagename) return;
  const submitForm = new FormData();
  submitForm.append('content', editor.session.getValue());
  let res = await fetch('/page/wikitext/' + pagename, {
    method: 'POST',
    body: submitForm
  }).then(res => res.json());
  if (res.code === 0) {
    loadArticle(pagename);
    exitedEditor();
  }
}
