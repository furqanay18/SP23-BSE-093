const mongoose = require("mongoose");

let usersSchema = mongoose.Schema({
  name: String,
  email: String,
  password: String,
  role: [String], // Array of roles, e.g., ['admin', 'user']
});

let UserModel = mongoose.model("User", usersSchema);

module.exports = UserModel;
