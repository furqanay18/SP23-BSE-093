const express = require("express");
let routers = express.Router();

const Order =   require("../../models/ordermodel");
const Product = require("../../models/productsmodel");
const Shop = require("../../models/shopmodel");
const mongoose = require("mongoose");
const Rider = require("../../models/ridermodel");

routers.post("/checkout", async (req, res) => {
  try {
    const { name, email, phone, address, paymentMethod } = req.body;
    const cart = req.cookies.cart;

    if (!Array.isArray(cart) || cart.length === 0) {
      return res.status(400).send("Cart is empty or invalid.");
    }

    let totalAmount = 0;
    const shopOrdersMap = {}; // key: shopId, value: { products: [], total: 0 }

    for (const item of cart) {
      if (!mongoose.Types.ObjectId.isValid(item.id)) continue;

      const product = await Product.findById(item.id);
      if (!product) continue;

      const quantity = item.quantity || 1;
      const price = product.price;
      const shopId = product.shopId.toString(); // Convert to string for consistent map keys

      if (!shopOrdersMap[shopId]) {
        shopOrdersMap[shopId] = { products: [], total: 0 };
      }

      shopOrdersMap[shopId].products.push({
        productId: product._id,
        quantity,
        price
      });

      shopOrdersMap[shopId].total += price * quantity;
    }

    const orderPromises = [];

    for (const shopId in shopOrdersMap) {
      const { products, total } = shopOrdersMap[shopId];

      const newOrder = new Order({
        customer: { name, email, phone, address },
        products,
        totalAmount: total,
        paymentMethod,
        shopId
      });

      orderPromises.push(newOrder.save());
    }

    await Promise.all(orderPromises);

    res.clearCookie("cart");
    return res.redirect("/order-success");

  } catch (error) {
    console.error("Checkout Error:", error.message, error.stack);
    return res.status(500).send("An error occurred during checkout.");
  }
});

routers.get('/order-success', (req, res) => {
  res.render('order-success');
});



const requireShopOwner = (req, res, next) => {
  // Assume shop owner's ID is stored in req.session.shopId
  if (!req.session.shopId) {
    return res.status(401).send("Unauthorized. Please log in as shop owner.");
  }
  next();
};

// GET /shop/orders
routers.get("/shop/orders", requireShopOwner, async (req, res) => {
  try {
    const shopId = req.session.shopId;

    const shop = await Shop.findById(shopId); // get current shop info
    const orders = await Order.find({ shopId })
      .sort({ createdAt: -1 })
      .populate("products.productId")
      .populate("rider");

    const riders = await Rider.find({ city: shop.city }); // get same-city riders only

    res.render("order", { orders, riders });
  } catch (err) {
    console.error("Failed to fetch orders:", err);
    res.status(500).send("Failed to load orders.");
  }
});





routers.post('/shop/orders/:orderId/assign-rider', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { riderId } = req.body;

    if (!riderId) return res.status(400).send('Rider ID is required');

    // Fetch order and shop
    const order = await Order.findById(orderId);
    if (!order) return res.status(404).send('Order not found');

    const shop = await Shop.findById(req.session.shopId);
    if (!shop) return res.status(403).send('Shop not found or not logged in');

    // Fetch rider and validate city
    const rider = await Rider.findById(riderId);
    if (!rider) return res.status(404).send('Rider not found');

    if (rider.city !== shop.city) {
      return res.status(400).send('Cannot assign a rider from a different city.');
    }

    // Assign rider
    order.rider = riderId;
    order.deliveryStatus = 'assigned';
    await order.save();

    res.redirect('/shop/orders');
  } catch (err) {
    console.error('Error assigning rider:', err);
    res.status(500).send('Server Error');
  }
});


module.exports=routers;