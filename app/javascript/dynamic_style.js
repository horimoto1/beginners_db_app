// 記事のステータスの色を設定する
function articleStatusColor() {
  const articleStatus = document.getElementById("article_status");
  if (articleStatus === null) {
    return;
  }

  if (articleStatus.value === "published") {
    articleStatus.style.setProperty("color", "#0000ff");
  } else {
    articleStatus.style.setProperty("color", "#ff0000");
  }
}

// ページ読み込み時の初期化処理
document.addEventListener("turbolinks:load", () => {
  document.addEventListener("change", () => {
    articleStatusColor();
  });

  articleStatusColor();
});
