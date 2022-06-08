// サイドメニューを閉じる
function close_side_menu() {
  const element = document.getElementById("side-menu-toggle");
  if (element !== null) {
    element.checked = false;
  }
}

// キーワードが未入力の場合は検索を実行しない
function search_form_check(e) {
  var element = e.target;
  // クリック位置によっては子要素がイベント発生元になるため調整する
  while (element.getAttribute("class") !== "search-button") {
    element = element.parentElement;
    if(element === null) {
      return;
    }
  }

  // 直前の兄弟要素を取得
  const keyword = element.previousElementSibling;

  // 空文字はfalseと評価される
  if(!keyword.value.trim()) {
    // クリックをキャンセルする
    e.preventDefault();
  }
}

// HTML全体が読み込まれてからイベントを登録する
document.addEventListener("DOMContentLoaded", () => {
  document.addEventListener("click", (e) => {
    // サイドメニューの外側をクリックした際はサイドメニューを閉じる
    if(!e.target.closest(".side-menu")) {
      close_side_menu();
    }

    // キーワードが未入力かどうかチェックする
    if(e.target.closest(".search-button")) {
      search_form_check(e);
    }
  })
})

// turbolinksでページ遷移時の調整
window.addEventListener("turbolinks:visit", () => {
  // 一瞬だけサイドメニューが表示されてしまう場合があるため
  close_side_menu();
})
