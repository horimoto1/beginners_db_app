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

    // エディタに画像がドラッグ&ドロップされた際の処理
    inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
      uploadUrl: "/attachments", // POSTで送信するパス
      uploadFieldName: "image", // パラメータのキー
      allowedTypes: ["image/jpeg", "image/png", "image/jpg", "image/gif"],
      extraHeaders: { "X-CSRF-Token": Rails.csrfToken() }, // CSRF対策
    });
  }
})

// turbolinksでページ遷移時にMarkdownエディタを削除する
// 戻るでページ遷移するとMarkdownエディタが複数表示されるため
window.addEventListener("turbolinks:visit", () => {
  if (simplemde !== null) {
    // Markdownエディタをtextareaに戻す
    simplemde.toTextArea();
    simplemde = null;
  }
})
