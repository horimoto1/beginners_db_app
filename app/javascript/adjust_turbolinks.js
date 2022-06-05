// フラッシュを消す
function erase_flash() {
  const elements = document.getElementsByClassName("flash");
  for (var i = 0; i < elements.length; i++) {
    elements[i].remove();
  }
}

// 目次の開閉状態をリセットする
function reset_toc() {
  const element = document.getElementById("toc-toggle");
  element.checked = false;
}

// turbolinksでページ遷移時の調整
window.addEventListener("turbolinks:visit", () => {
  // 一瞬だけ前のフラッシュが表示されるため
  erase_flash();

  // 一瞬だけ前の目次の開閉状態が表示されるため
  reset_toc();
})
