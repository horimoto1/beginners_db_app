/* globals inlineAttachment */

import "inline-attachment/src/inline-attachment"
import "inline-attachment/src/codemirror-4.inline-attachment"
import SimpleMDE from "simplemde"
import Rails from "@rails/ujs"
import { marked } from "marked"

let simplemde = null

// エラーメッセージを表示する
function showErrorMessages(response) {
  const json = JSON.parse(response.response)
  if (json.errors === undefined) {
    return
  }

  let errorMessages = ""
  for (let i = 0; i < json.errors.length; i++) {
    errorMessages += json.errors[i]
    if (i < json.errors.length - 1) {
      errorMessages += "\n"
    }
  }

  alert(errorMessages)
}

document.addEventListener("turbolinks:load", () => {
  // Markdownエディタを設定する
  const element = document.getElementById("article_content")
  if (element === null) {
    return
  }

  // プレビュー時のオプション
  marked.setOptions({
    // 改行を<br>に変換する
    breaks: true
  })

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
      setTimeout(() => {
        preview.innerHTML = marked(plainText)
      }, 250)

      return "Loading..."
    }
  })
  // エディタに画像がドラッグ&ドロップされた際の処理
  inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
    uploadUrl: "/attachments", // POSTで送信するパス
    uploadFieldName: "image", // パラメータのキー
    allowedTypes: ["image/jpeg", "image/png", "image/gif", "image/svg+xml"],
    extraHeaders: { "X-CSRF-Token": Rails.csrfToken() }, // CSRF対策
    onFileUploadResponse: (response) => {
      showErrorMessages(response)
    }
  })
})

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // 戻るボタンでページ遷移するとMarkdownエディタが増殖するため削除する
  if (simplemde !== null) {
    simplemde.toTextArea()
    simplemde = null
  }
})
