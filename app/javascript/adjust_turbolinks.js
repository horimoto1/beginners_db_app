// turbolinksでページ遷移時にフラッシュを消す
// ページ遷移後に一瞬だけフラッシュが表示されてしまう場合があるため
window.addEventListener("turbolinks:visit", () => {
  var elements = document.getElementsByClassName("flash");
  for (var i = 0; i < elements.length; i++) {
    elements[i].remove();
  }
})
