// サイドメニューを閉じる
function closeSideMenu() {
  const element = document.getElementById("side-menu-toggle");
  if (element !== null) {
    element.checked = false;
  }
}

// 編集メニューを閉じる
function closeEditMenu() {
  const element = document.getElementById("edit-menu-toggle");
  if (element !== null) {
    element.checked = false;
  }
}

// 検索フォームを閉じる
function closeSearchForm() {
  const toggle = document.getElementById("search-form-toggle");
  if (toggle !== null) {
    toggle.checked = false;
  }
}

// 検索フォームの入力状態をチェックする
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
    // キーワードが未入力の場合は検索を実行しない
    e.preventDefault();
  }
}

// 検索フォームのトグルボタンを設定する
function setupSearchFormToggle() {
  const toggle = document.getElementById("search-form-toggle");
  if (toggle === null) {
    return;
  }

  toggle.addEventListener("change", (e) => {
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
  document.addEventListener("click", (e) => {
    // サイドメニューの外側をクリックした場合はサイドメニューを閉じる
    if (!e.target.closest(".side-menu")) {
      closeSideMenu();
    }

    // 編集メニューの外側をクリックした場合は編集メニューを閉じる
    if (!e.target.closest(".edit-menu")) {
      closeEditMenu();
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

  // 初期設定
  handleMatchMedia(mediaQuery);
});

// ページ遷移時のリセット処理
document.addEventListener("turbolinks:visit", () => {
  // サイドメニューの表示状態がリセットされない場合があるため
  closeSideMenu();

  // 編集メニューの表示状態がリセットされない場合があるため
  closeEditMenu();

  // 検索フォームの表示状態がリセットされない場合があるため
  closeSearchForm();
});
