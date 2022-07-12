/* globals inlineAttachment */

import "inline-attachment/src/inline-attachment"
import "inline-attachment/src/codemirror-4.inline-attachment"
import SimpleMDE from "simplemde"
import Rails from "@rails/ujs"

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

// マークダウンをパースする
function markdownParse(plainText, preview) {
  const xhr = new XMLHttpRequest()
  xhr.open("POST", "/preview", true)
  xhr.setRequestHeader("X-CSRF-Token", Rails.csrfToken())
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")

  // 送信するデータをURLエンコードする
  // application/x-www-form-urlencodedのため、空白の%20を+に全て置換する
  const data = `text=${encodeURIComponent(plainText)}`.replace(/%20/g, "+")
  xhr.send(data)

  xhr.onload = () => {
    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
      const json = JSON.parse(xhr.response)
      preview.innerHTML = json.markdown
    } else {
      preview.innerHTML = "パースに失敗しました"
    }
  }
}

document.addEventListener("turbolinks:load", () => {
  // Markdownエディタを設定する
  const element = document.getElementById("article_content")
  if (element === null) {
    return
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
      markdownParse(plainText, preview)

      return "Loading..."
    }
  })

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
