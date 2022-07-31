// 記事のステータスの色を設定する
function setArticleStatusColor() {
  const element = document.getElementById("article_status");
  if (element === null) {
    return;
  }

  if (element.value === "published") {
    element.style.setProperty("color", "#0000ff");
  } else {
    element.style.setProperty("color", "#ff0000");
  }
}

// 記事のステータスのイベントを設定する
function setupArticleStatus() {
  const element = document.getElementById("article_status");
  if (element === null) {
    return;
  }

  element.addEventListener("change", () => {
    setArticleStatusColor();
  });
}

// ファイル選択ダイアログを表示する
function showInputFileDialog() {
  const element = document.getElementById("article_image");
  if (element === null) {
    return;
  }

  element.click();
}

// ファイル選択ボタンのイベントを設定する
function setupInputFileButton() {
  const element = document.getElementById("input-file-button");
  if (element === null) {
    return;
  }

  element.addEventListener("click", () => {
    showInputFileDialog();
  });
}

// ファイル選択テキストに値を設定する
function setInputFileTextValue() {
  const inputfileText = document.getElementById("input-file-text");
  if (inputfileText === null) {
    return;
  }

  const inputFileDialog = document.getElementById("article_image");
  if (inputFileDialog === null) {
    return;
  }

  if (inputFileDialog.files[0] != null) {
    inputfileText.value = inputFileDialog.files[0].name;
  } else {
    inputfileText.value = "";
  }
}

// ファイル選択ダイアログのイベントを設定する
function setupInputFileDialog() {
  const element = document.getElementById("article_image");
  if (element === null) {
    return;
  }

  element.addEventListener("change", () => {
    setInputFileTextValue();
  });
}

// ページ読み込み時の初期化処理
document.addEventListener("turbolinks:load", () => {
  setArticleStatusColor();

  setupArticleStatus();

  setupInputFileButton();

  setupInputFileDialog();
});
