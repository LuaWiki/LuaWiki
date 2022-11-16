// generate new modal
// return: Element
function newModal({ title, img, content, yes, no, yes_text, no_text }) {
  const dialog = document.createElement('dialog');
  if (img) {
    const image = new Image();
    image.src = img;
    dialog.appendChild(image);
  }
  if (title) {
    const h2 = document.createElement('h2');
    h2.innerHTML = title;
    dialog.appendChild(h2);
  }
  if (content) {
    const p = document.createElement('p');
    p.innerHTML = content;
    dialog.appendChild(p);
  }
  const btn_container = document.createElement('div');
  btn_container.style.display = 'flex';
  btn_container.style.justifyContent = 'space-around';

  const no_btn = document.createElement('button');
  no_btn.className = 'button-outline';
  no_btn.innerText = no_text || '关闭';
  if (no && typeof no === 'function') {
    no_btn.addEventListener('click', () => {
      no();
      dialog.remove();
    });
  } else {
    no_btn.addEventListener('click', () => {
      dialog.close();
      dialog.remove();
    });
  }
  btn_container.appendChild(no_btn);
  
  if (yes) {
    const yes_btn = document.createElement('button');
    yes_btn.innerText = yes_text || '确认';
    if (yes && typeof yes === 'function') {
      yes_btn.addEventListener('click', () => {
        yes();
        dialog.remove();
      });
    }
    btn_container.appendChild(yes_btn);
  }
  dialog.appendChild(btn_container);
  document.body.appendChild(dialog);
  dialog.showModal();
}
