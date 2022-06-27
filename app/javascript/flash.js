document.addEventListener("turbolinks:load", () => {
  // フラッシュをフェードアウトさせる
  setTimeout(() => {
    $(".flash").fadeOut(1000);
  }, 2000);
});
