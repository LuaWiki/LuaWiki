local title = ngx.unescape_uri(ngx.var.arg_title)

local fetch_wikitext = require('fetch_wikitext')
local flag, wikitext = fetch_wikitext(title)

local parser_output = ''
if flag then
  local nonparse = require('core/nonparse')
  local parser = require('core/parser')
  local wiki_state = {
    title = title,
    npb_index = 0,
    nw_index = 0,
    npb_cache = {},
    nw_cache = {}
  }

  -- start timer
  ngx.update_time()
  local begin_time = ngx.now()

  wikitext = nonparse.decorate(wiki_state, wikitext)

  local preprocessor = require('core/preprocessor').new(wiki_state)
  wikitext = preprocessor:process(wikitext)
  parser_output = parser.parse(wiki_state, wikitext)

  -- end timer
  ngx.update_time()

  local html_stag_map = {}
  local html_single_tags = {
    'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 
    'link', 'meta', 'param', 'source', 'track', 'wbr'
  }
  for _, v in ipairs(html_single_tags) do
    html_stag_map[v] = true
  end
  
  parser_output = '<h1>' .. title:gsub('_', ' ') .. '</h1>' .. parser_output:gsub('<((%a+)[^>]-)/>', function(p1, p2)
    if not html_stag_map[p2] then
      if p2 == 'references' then
        return '<div><' .. p1 .. '></' .. p2 .. '></div>'
      else
        return '<' .. p1 .. '></' .. p2 .. '>'
      end
    end
  end) .. '<!-- Total parse time: ' .. (ngx.now() - begin_time) .. '-->'
else
  parser_output = wikitext or 'Page not found'
end

local mainpage_html = ([=[<!DOCTYPE html>
<html>
<head>
  <title>维基百科，自由的百科全书</title>
  <!--<link rel="stylesheet" href="https://picocss.com/css/pico.min.css">-->
  <link rel="stylesheet" href="https://cdn.staticfile.org/normalize/8.0.1/normalize.css">
  <link rel="stylesheet" href="https://cdn.staticfile.org/milligram/1.4.1/milligram.css">
  <link rel="stylesheet" href="/ooicon/style.css">
  <link rel="stylesheet" href="https://cdn.staticfile.org/KaTeX/0.15.6/katex.min.css">
  <link rel="stylesheet" href="https://cdn.staticfile.org/highlight.js/11.5.1/styles/default.min.css">
  <link rel="stylesheet" type="text/css" href="/wiki.css">
</head>
<style>
html, body {
  height: 100%;
}
body {
  font-weight: 400;
  color: #2b3135;
}
body > nav {
  display: flex;
  justify-content: space-between;
  background: #5c87a6;
}
body > nav ul {
  display: flex;
  margin-bottom: 0;
  list-style: none;
}
body > nav li {
  margin-bottom: 0;
  padding: 0.5em 1em;
  color: #fff;
}
body > nav a, body > nav a:focus, body > nav a:hover {
  color: #fff;
}
body > nav a:hover {
  opacity: 0.8;
}
.logo {
  display: inline-block;
  padding: 0.2em;
  line-height: 1;
  background: black;
  border-radius: 50%;
  color: #fff;
}
#content {
  height: calc(100% - 41.6px);
  overflow: auto;
  padding: 1em;
}
#content.has-toc {
  display: grid;
  grid-template-columns: 13em 1fr;
  grid-column-gap: 2em;
}
#content aside {
  position: sticky;
  top: 0;
  align-self: start;
  height: 90vh;
  overflow: auto;
}
#content aside ul {
  list-style: none;
}
#content aside li a {
  color: #2b3135;
  opacity: 0.7;
}
#content aside li:hover > a, #content aside li.active > a {
  opacity: 1;
  font-weight: bold;
}
@supports (-moz-appearance:none) {
  .parser-output {
    text-align: justify;
    hyphens: auto;
  }
}
</style>
<body>
  <nav class="container-fluid">
    <ul>
      <li>
        <span class="logo"><i class="icon icon-logo-Wikipedia"></i></span>
        <strong>LUAWIKI</strong>
      </li>
    </ul>
    <ul>
      <li>
        <a href="javascript:openSearch()"><i class="icon icon-search"></i></a>
      </li>
      <li>
        <a href="javascript:gotoLogin()"><i class="icon icon-logIn-ltr"></i></a>
      </li>
    </ul>
  </nav>
  <div id="content" class="has-toc">
    <aside>
    </aside>
    <article id="parser-output">_CONTENT_</article>
  </div>
  
<script src="/simplequery.js"></script>
<script defer src="https://cdn.staticfile.org/KaTeX/0.15.6/katex.min.js"></script>
<script defer src="https://cdn.staticfile.org/KaTeX/0.15.6/contrib/mhchem.min.js"></script>
<script defer src="https://cdn.staticfile.org/highlight.js/11.5.1/highlight.min.js"></script>
<script src="/zh_convert.js"></script>
<script src="/wiki.js"></script>
<script>
let outputDiv = document.getElementById('parser-output');
$(document).ready(function(){
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
});

function buildToc() {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (entry.intersectionRatio > 0) {
        document.querySelector(`aside li a[href="#${id}"]`).parentElement.classList.add('active');
      } else {
        document.querySelector(`aside li a[href="#${id}"]`).parentElement.classList.remove('active');
      }
    });
  });

  document.querySelectorAll('section[id]').forEach((section) => {
    observer.observe(section);
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

const hashStore = [ { hash: '' } ];
let hashIndex = 0
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
</script>
</body>
</html>
]=]):gsub('_CONTENT_', (parser_output:gsub('%%', '%%%%')))

ngx.say(mainpage_html)