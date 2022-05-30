// HTML全体が読み込まれてからイベントを登録する
document.addEventListener("DOMContentLoaded", () => {
  // サイドメニューの外側をクリックした際はサイドメニューを閉じる
  document.addEventListener("click", (e) => {
    // 子要素に.side-menuを含むか？
    if(!e.target.closest(".side-menu")) {
      const element = document.getElementById("side-menu-toggle");
      element.checked = false;
    }
  })

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

  const buttons = document.getElementsByClassName("search-button");
  for(let i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener("click", (e) => {
      search_form_check(e);
      // イベントの伝播を止める
      e.stopPropagation();
    });
  }
})
