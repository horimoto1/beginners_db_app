import 'inline-attachment/src/inline-attachment';
import 'inline-attachment/src/codemirror-4.inline-attachment';
import SimpleMDE from 'simplemde';
import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';

window.addEventListener('turbolinks:load', function () {
  // textareaをMarkdownエディタにする
  const simplemde = new SimpleMDE({
    element: document.getElementById("markdown_editor"),
    // ツールバーの設定
    toolbar: ["bold", "strikethrough", "heading", "|",
              "quote","code", "unordered-list", "ordered-list", "|",
              "link", "image", "table", "|",
              "preview", "side-by-side", "fullscreen"],
  });

  // エディタに画像がドラッグ&ドロップされた際の処理
  inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
    uploadUrl: '/attachments/create', // POSTするパス
    uploadFieldName: 'image', // paramsフィールド
    allowedTypes: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'],
    extraHeaders: { 'X-CSRF-Token': Rails.csrfToken() }, // CSRF対策
  });
});

Turbolinks.start();
