import ClipboardJS from "clipboard"

let clip = null

document.addEventListener("turbolinks:load", () => {
  // クリップボードへのコピーボタンを設定する
  if ($(".clip-button").length > 0) {
    clip = new ClipboardJS(".clip-button")
  }
})

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  if (clip !== null) {
    clip.destroy()
    clip = null
  }
})
