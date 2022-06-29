// フラッシュを消す
function eraseFlash() {
  const elements = document.getElementsByClassName("flash")
  for (let i = 0; i < elements.length; i++) {
    elements[i].remove()
  }
}

// 目次の開閉状態をリセットする
function resetToc() {
  const element = document.getElementById("toc-toggle")
  if (element !== null) {
    element.checked = false
  }
}

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // 一瞬だけ前ページのフラッシュが表示されるため
  eraseFlash()

  // 一瞬だけ前ページの目次の開閉状態が表示されるため
  resetToc()
})
