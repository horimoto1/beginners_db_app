const https = require("https");

const URL = "https://majestic-joshua-tree-45635.herokuapp.com";
const INTERVAL_MSEC = 10 * 60 * 1000;

setInterval(() => {
  https
    .get(URL, (res) => {
      // eslint-disable-next-line no-console
      console.log(res, URL);
    })
    .on("error", (err) => {
      // eslint-disable-next-line no-console
      console.log(err, URL);
    });
}, INTERVAL_MSEC);
