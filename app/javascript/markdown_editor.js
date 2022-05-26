import "inline-attachment/src/inline-attachment";
import "inline-attachment/src/codemirror-4.inline-attachment";
import SimpleMDE from "simplemde";
import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import { marked } from "marked";

window.addEventListener("turbolinks:load", function () {
  // textareaをMarkdownエディタにする
  const simplemde = new SimpleMDE({
    element: document.getElementById("markdown_editor"),
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

  // エディタに画像がドラッグ&ドロップされた際の処理
  inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
    uploadUrl: "/attachments", // POSTで送信するパス
    uploadFieldName: "image", // パラメータのキー
    allowedTypes: ["image/jpeg", "image/png", "image/jpg", "image/gif"],
    extraHeaders: { "X-CSRF-Token": Rails.csrfToken() }, // CSRF対策
  });
});

Turbolinks.start();
