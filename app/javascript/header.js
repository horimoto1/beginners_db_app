// サイドメニューを閉じる
function closeSideMenu() {
  const element = document.getElementById("side-menu-toggle");
  if (element !== null) {
    element.checked = false;
  }
}

// キーワードが未入力の場合は検索を実行しない
function searchFormCheck(e) {
  let element = e.target;
  // クリック位置によっては子要素がイベント発生元になるため調整する
  while (element.getAttribute("class") !== "search-button") {
    element = element.parentElement;
    if (element === null) {
      return;
    }
  }

  // 直前の兄弟要素を取得
  const keyword = element.previousElementSibling;

  // 空文字はfalseと評価される
  if (!keyword.value.trim()) {
    // クリックをキャンセルする
    e.preventDefault();
  }
}

// 検索フォームのトグルボタンを設定する
function setupSearchFormToggle() {
  const element = document.getElementById("search-form-toggle");
  if (element === null) {
    return;
  }

  element.addEventListener("change", (e) => {
    const searchForm = document.querySelector(".search-form");
    if (searchForm === null) {
      return;
    }

    if (e.target.checked) {
      searchForm.style.setProperty("display", "block", "");
    } else {
      searchForm.style.setProperty("display", "none", "");
    }
  });
}

// メディアクエリを設定する
function handleMatchMedia(e) {
  const searchForm = document.querySelector(".search-form");
  if (searchForm === null) {
    return;
  }

  const toggle = document.getElementById("search-form-toggle");
  if (toggle === null) {
    return;
  }

  if (e.matches) {
    if (toggle.checked) {
      searchForm.style.setProperty("display", "block", "");
    } else {
      searchForm.style.setProperty("display", "none", "");
    }
  } else {
    searchForm.style.setProperty("display", "block", "");
  }
}

// ページ読み込み時の初期化処理
document.addEventListener("turbolinks:load", () => {
  // HTML全体が読み込まれてからイベントを登録する
  document.addEventListener("click", (e) => {
    // サイドメニューの外側をクリックした際はサイドメニューを閉じる
    if (!e.target.closest(".side-menu")) {
      closeSideMenu();
    }

    // キーワードが未入力かどうかチェックする
    if (e.target.closest(".search-button")) {
      searchFormCheck(e);
    }
  });

  // 検索フォームのトグルボタンを設定する
  setupSearchFormToggle();

  // メディアクエリを設定する
  const mediaQuery = window.matchMedia("(max-width: 800px)");
  mediaQuery.addEventListener("change", (e) => {
    handleMatchMedia(e);
  });
});

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // 一瞬だけ前ページのサイドメニューが表示されてしまう場合があるため
  closeSideMenu();
});
