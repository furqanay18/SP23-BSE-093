// models/shopmodel.js
const mongoose = require('mongoose');

const shopSchema = new mongoose.Schema({
  name: String,
  address: String,
  city:String,
  email: String,
  phone: String,
  password: String,
  logo: String,
  pictures: [String],
  banners: [String],
  transaction_id: String,
  payment_screenshot: String, // <-- Added
  isPaid: { type: Boolean, default: false },
  status: { type: String, default: 'pending' } // pending, approved, rejected
});

const Shop = mongoose.model('Shop', shopSchema);
module.exports=Shop;
