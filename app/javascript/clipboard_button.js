import ClipboardJS from "clipboard";

var clip = null;

// クリップボードへのコピーボタンを設定する
window.addEventListener("turbolinks:load", () => {
  if ($(".clip-button").length > 0) {
    clip = new ClipboardJS(".clip-button");
  }
});

window.addEventListener("turbolinks:visit", () => {
  if (clip !== null) {
    clip.destroy();
    clip = null;
  }
});
