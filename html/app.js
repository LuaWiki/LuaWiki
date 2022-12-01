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

function elInViewport(el) {
  const rect = el.getBoundingClientRect();
  return (rect.top >= 41.6 && rect.bottom <= window.innerHeight);
}

let sectionObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (entry.intersectionRatio > 0) {
        const $me = $(`aside li a[href="#${id}"]`);
        let parent = $me.parent().get(0);
        parent.className = 'active';
        if (entry.target.className === 'h3sec') {
          if (!elInViewport(parent)) {
            parent.scrollIntoView();
          }
        } else if (entry.target.className === 'h2sec') {
          if (!elInViewport(parent)) {
            parent.scrollIntoView()
          }
        }
      } else {
        $(`aside li a[href="#${id}"]`).parent().removeClass('active');
      }
    });
  });

$(document).ready(mainContentLoaded);

async function loadArticle(title, noCache) {
  let res = await fetch(`/page/html/${title}` + (noCache ? '?r=' + Math.random(): ''))
              .then(res => res.json());
  if (res.code === 0) {
    html = res.result + `<!-- Total parse time: ${res.parse_time}-->`;
    html = `<aside></aside><article id="parser-output">${html}</article>`;
    routeHandler(title, html, decodeURIComponent(title));
    mainContentLoaded();
  } else {
    newModal({
      title: '页面不存在',
      img: '/image/404.svg',
      yes_text: '创建条目',
      yes: () => {
        editPage(title)
      }
    })
  }
}

function mainContentLoaded() {
  outputDiv = document.getElementById('parser-output');
  hashStore = [ { hash: '' } ];
  hashIndex = 0;
  outputDiv.innerHTML = doMwConvert(outputDiv.innerHTML);
  $content.find('a[href^="/wiki/"]').click(async function(event) {
    let newTitle = this.href.match(/\/wiki\/([^#]*)/) && RegExp.$1;
    loadArticle(newTitle);
  });
  
  document.title = outputDiv.children[0].innerText + ' - 维基百科，自由的百科全书'
  
  buildToc();
  
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
  
  const tocArr = [ { name: '(序言)', link: '#toc0', children: [] } ];
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

// set page content and run scripts
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

// background request html content and set content and route
async function getRemoteHTML(url, route, title, type) {
  let html = await fetch(url).then(res => res.text());
  routeHandler(route, html, title, type);
}

function gotoLogin() {
  location.href = '/login.html?returnUrl=' + location.pathname;
}

async function editPage(pageName) {
  window.pagename = pageName || lastPath.match(/\/wiki\/([^#]+)/) && RegExp.$1;
  if (!pagename) return;
  getRemoteHTML('/editor.html', '/wiki/' + window.pagename + '#/edit', '编辑', 'tool');
  appData.showEdit = false;
  appData.showSubmit = true;
}

async function historyPage() {
  window.pagename = lastPath.match(/\/wiki\/([^#]+)/) && RegExp.$1;
  if (!pagename) return;
  getRemoteHTML('/history.html', '/wiki/' + window.pagename + '#/history', '历史', 'tool');
}

async function submitPage() {
  if (!window.editor) return;
  let pagename = lastPath.match(/\/wiki\/([^#]+)/) && RegExp.$1;
  if (!pagename) return;
  
  newModal({
    title: '添加概要',
    img: '/image/submit.svg',
    content: `
      <form>
        <fieldset>
          <label for="nameField">编辑摘要</label>
          <textarea type="text" id="summary" placeholder="总结一下编辑的内容"></textarea>
        </fieldset>
      </form>
    `,
    yes_text: '发布',
    yes: async () => {
      const submitForm = new FormData();
      submitForm.append('content', editor.session.getValue());
      submitForm.append('comment', $('#summary').val());
      let res = await fetch('/page/wikitext/' + pagename, {
        method: 'POST',
        body: submitForm
      }).then(res => res.json());
      if (res.code === 0) {
        loadArticle(pagename, true);
        exitedEditor();
      }
    }
  })
}

function cancelEdit() {
  if (!window.editor) return;
  history.go(-1);
}
