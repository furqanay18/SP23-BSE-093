let User = require("../models/user-model");

module.exports = async function (req, res, next) {
  let defaultUser = await User.findOne({ email: "usman.akram@gmail.com" });
  if (defaultUser) {
    req.session.user = defaultUser;
    res.locals.user = req.session.user;
    req.user = req.session.user;
  }
  next();
};