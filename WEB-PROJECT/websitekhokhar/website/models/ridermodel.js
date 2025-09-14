const mongoose = require("mongoose");
const riderSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String, required: true, trim: true },
  city: {type:String, required:true,trim:true},
  password: { type: String, required: true },
    // Stored as plain text (not recommended for production)
  active: { type: Boolean, default: true },   // Whether rider is active or suspended
  createdAt: { type: Date, default: Date.now }
});

const Rider = mongoose.model("Rider", riderSchema);
module.exports = Rider;
