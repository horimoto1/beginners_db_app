import ClipboardJS from "clipboard";

let clip = null;

// クリップボードのコピーボタンを設定する
function setupClipboard() {
  if ($(".clip-button").length > 0) {
    clip = new ClipboardJS(".clip-button");
  }
}

// クリップボードのコピーボタンをリセットする
function resetClipboard() {
  if (clip !== null) {
    clip.destroy();
    clip = null;
  }
}

// ページ読み込み時の初期化処理
document.addEventListener("turbolinks:load", () => {
  // クリップボードのコピーボタンを設定する
  setupClipboard();
});

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // クリップボードのコピーボタンをリセットする
  resetClipboard();
});
