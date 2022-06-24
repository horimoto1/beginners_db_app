import ClipboardJS from "clipboard";

var clip = null;

// クリップボードへのコピーボタンを設定する
document.addEventListener("turbolinks:load", () => {
  if ($(".clip-button").length > 0) {
    clip = new ClipboardJS(".clip-button");
  }
});

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  if (clip !== null) {
    clip.destroy();
    clip = null;
  }
});
