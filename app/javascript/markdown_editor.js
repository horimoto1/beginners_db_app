import "inline-attachment/src/inline-attachment";
import "inline-attachment/src/codemirror-4.inline-attachment";
import SimpleMDE from "simplemde";
import Rails from "@rails/ujs";
import { marked } from "marked";

var simplemde = null;

// turbolinksでページ読み込み時にMarkdownエディタを設定する
window.addEventListener("turbolinks:load", () => {
  const element = document.getElementById("markdown_editor");
  if (element != null) {
    // プレビュー時のオプション
    marked.setOptions({
      // 改行を<br>に変換する
      breaks: true,
    });

    // textareaをMarkdownエディタにする
    simplemde = new SimpleMDE({
      element: element,
      // ツールバーのカスタマイズ
      toolbar: ["bold", "strikethrough", "heading", "|",
                "quote","code", "unordered-list", "ordered-list", "|",
                "link", "image", "table", "|",
                "preview", "side-by-side", "fullscreen"],
      // スペルチェックを無効にする
      spellChecker: false,
      // 編集内容を元のtextareaに即座に反映する
      forceSync: true,
      // プレビューを有効にする
      previewRender: function(plainText, preview) {
        setTimeout( function() {
          preview.innerHTML = marked(plainText);
        }, 250);

        return "Loading...";
      },
    });

    // エラーメッセージを表示する
    function show_error_messages(response) {
      var json = JSON.parse(response.response);
      if (json["errors"] === undefined) {
        return;
      }

      var error_messages = "";
      for (var i = 0; i < json["errors"].length; i++) {
        error_messages += json["errors"][i];
        if (i < json["errors"].length - 1) {
          error_messages += "\n";
        }
      }

      alert(error_messages);
    }

    // エディタに画像がドラッグ&ドロップされた際の処理
    inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
      uploadUrl: "/attachments", // POSTで送信するパス
      uploadFieldName: "image", // パラメータのキー
      allowedTypes: ["image/jpeg", "image/png", "image/gif", "image/svg+xml"],
      extraHeaders: { "X-CSRF-Token": Rails.csrfToken() }, // CSRF対策
      onFileUploadResponse: (response) => { show_error_messages(response) },
    });
  }
})

// turbolinksでページ遷移時にMarkdownエディタを削除する
// 戻るボタンでページ遷移するとMarkdownエディタが増殖するため
window.addEventListener("turbolinks:visit", () => {
  if (simplemde !== null) {
    // Markdownエディタをtextareaに戻す
    simplemde.toTextArea();
    simplemde = null;
  }
})
