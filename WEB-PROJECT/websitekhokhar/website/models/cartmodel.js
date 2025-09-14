// models/cartmodel.js
const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  shopId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Shop'
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Category'
  },
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Product'
  },
  title: String,
  picture: String,
  price: Number,
  quantity: Number
});

module.exports = mongoose.model('Cart', cartSchema);
