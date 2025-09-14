const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  customer: {
    name: { type: String, required: true },
    email: { type: String, required: true },
    phone: { type: String, required: true },
    address: { type: String, required: true }
  },
  products: [
    {
      productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true
      },
      quantity: {
        type: Number,
        required: true,
        default: 1
      },
      price: {
        type: Number,
        required: true
      }
    }
  ],
  totalAmount: {
    type: Number,
    required: true
  },
  paymentMethod: {
    type: String,
    enum: ["credit", "paypal", "cod"],
    required: true
  },
  status: {
    type: String,
    enum: ["pending", "processing", "shipped", "delivered", "cancelled"],
    default: "pending"
  },
  shopId: {
    type: mongoose.Schema.Types.ObjectId,

    ref: "Shop",
    required: true
  },

  // 🚴 Rider assignment
  rider: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Rider",
    default: null
  },

  // 🚦 Rider delivery flow
  deliveryStatus: {
    type: String,
    enum: ["not_assigned", "assigned", "picked_up", "delivered"],
    default: "not_assigned"
  },

  // 🛑 Rider can reject an order
  riderStatus: {
    type: String,
    enum: ["not_assigned", "accepted", "rejected"],
    default: "not_assigned"
  },
  riderRejectionReason: {
    type: String,
    default: null
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});


const OrderModel = mongoose.model("Order", orderSchema);

module.exports = OrderModel;
