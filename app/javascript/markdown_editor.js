/* globals inlineAttachment */

import "inline-attachment/src/inline-attachment";
import "inline-attachment/src/codemirror-4.inline-attachment";
import SimpleMDE from "simplemde";
import Rails from "@rails/ujs";

let simplemde = null;

// ファイルをMarkdownエディタにD&Dする
function dropFile(file) {
  if (file !== null && simplemde !== null) {
    const event = jQuery.Event("drop", { dataTransfer: { files: [file] } });
    const cm = simplemde.codemirror;
    cm.constructor.signal(cm, "drop", cm, event);
  }
}

// ファイル選択ダイアログを設定する
function setupInputFileDialog() {
  const element = document.getElementById("input-file");
  if (element === null) {
    return;
  }

  element.accept = "image/jpeg,image/png,image/gif,image/svg+xml";
  element.addEventListener("change", (e) => {
    dropFile(e.target.files[0]);
  });
}

// ファイル選択ダイアログを表示する
function showInputFileDialog() {
  const element = document.getElementById("input-file");
  if (element === null) {
    return;
  }

  element.click();
}

// エラーメッセージを表示する
function showErrorMessages(response) {
  const json = JSON.parse(response.response);
  if (json.errors === undefined) {
    return;
  }

  let errorMessages = "画像を投稿できませんでした";
  for (let i = 0; i < json.errors.length; i++) {
    errorMessages += `\n${json.errors[i]}`;
  }

  alert(errorMessages);
}

// マークダウンをパースする
function markdownParse(plainText, preview) {
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "/preview", true);
  xhr.setRequestHeader("X-CSRF-Token", Rails.csrfToken());
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  // 送信するデータをURLエンコードする
  // application/x-www-form-urlencodedのため、空白の%20を全て+に置換する
  const data = `text=${encodeURIComponent(plainText)}`.replace(/%20/g, "+");
  xhr.send(data);

  xhr.onload = () => {
    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
      const json = JSON.parse(xhr.response);
      preview.innerHTML = json.markdown;
    } else {
      preview.innerHTML = "パースに失敗しました";
    }
  };
}

// Markdownエディタを設定する
function setupMarkdownEditer() {
  // textareaを取得する
  const element = document.getElementById("article_content");
  if (element === null) {
    return;
  }

  // textareaをMarkdownエディタにする
  simplemde = new SimpleMDE({
    element,
    // ツールバーのカスタマイズ
    toolbar: [
      "bold",
      "strikethrough",
      "heading",
      "|",
      "quote",
      "code",
      "unordered-list",
      "ordered-list",
      "|",
      "link",
      "image",
      "table",
      {
        name: "file-upload",
        action: () => {
          // ファイル選択ダイアログを開く
          showInputFileDialog();
        },
        className: "fa fa-file",
        title: "File Upload"
      },
      "|",
      "preview",
      "side-by-side",
      "fullscreen"
    ],
    // スペルチェックを無効にする
    spellChecker: false,
    // 編集内容を元のtextareaに即座に反映する
    forceSync: true,
    // プレビューを有効にする
    previewRender(plainText, preview) {
      markdownParse(plainText, preview);

      return "Loading...";
    }
  });

  // エディタに画像がドラッグ&ドロップされた際の処理
  inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
    // POSTで送信するパス
    uploadUrl: "/attachments",
    // パラメータのキー
    uploadFieldName: "image",
    // content-type
    allowedTypes: ["image/jpeg", "image/png", "image/gif", "image/svg+xml"],
    // CSRF対策
    extraHeaders: { "X-CSRF-Token": Rails.csrfToken() },
    // アップロード後にエディタに埋め込むテキスト
    urlText: (filename, result) => `![${result.orig_file_name}](${filename})`,
    // オリジナルのファイル名を渡せるようにする
    remoteFilename: (file) => file.name,
    // アップロード後のイベント
    onFileUploadResponse: (response) => {
      showErrorMessages(response);
    }
  });
}

// Markdownエディタをリセットする
function resetMarkdownEditer() {
  if (simplemde !== null) {
    simplemde.toTextArea();
    simplemde = null;
  }
}

// ページ読み込み時の初期化処理
document.addEventListener("turbolinks:load", () => {
  // マークダウンエディタを設定する
  setupMarkdownEditer();

  // ファイル選択ダイアログを設定する
  setupInputFileDialog();
});

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // 戻るボタンなどでページ遷移するとMarkdownエディタが増殖するため
  resetMarkdownEditer();
});
