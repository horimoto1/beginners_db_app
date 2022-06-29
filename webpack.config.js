const env = process.env.RAILS_ENV || "development"
module.exports = require(`./config/webpack/${env}.js`)
