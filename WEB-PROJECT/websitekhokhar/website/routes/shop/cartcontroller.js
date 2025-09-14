const express = require("express");
let routers = express.Router();
let Product = require("../../models/productsmodel");

const Cart = require('../../models/cartmodel');

//let Order = require("../../models/order.model");
//const Review = require('../../models/review.model'); 
const mongoose = require("mongoose");


routers.get('/cart', async (req, res) => {
  const cart = req.cookies.cart || [];

  if (cart.length === 0) {
    return res.render('cart', { products: [], total: 0 });
  }

  const productIds = cart.map(item => item.id);

  const productsFromDb = await Product.find({ _id: { $in: productIds } })
    .populate('shopId')        // populate shop info
    .populate('category');     // populate category info

  // Match quantity from cookie
  const products = productsFromDb.map(product => {
    const cartItem = cart.find(item => item.id === product._id.toString());
    return {
      ...product.toObject(),
      quantity: cartItem ? cartItem.quantity : 1
    };
  });

  const total = products.reduce((sum, p) => sum + (p.price * p.quantity), 0);

  res.render('cart', { products, total: total.toFixed(2) });
});


routers.get("/add-to-cart/:id", async (req, res) => {
  const productId = req.params.id;

  // Validate the productId
  if (!mongoose.Types.ObjectId.isValid(productId)) {
    return res.status(400).send("Invalid product ID");
  }

  // Optional: check if the product actually exists
  const productExists = await Product.findById(productId);
  if (!productExists) {
    return res.status(404).send("Product not found");
  }

  // Get the cart from cookies or initialize it
  let cart = req.cookies.cart || [];

  // Check if the product already exists in the cart
  const existingProductIndex = cart.findIndex((item) => item.id === productId);

  if (existingProductIndex > -1) {
    // Increment quantity
    cart[existingProductIndex].quantity += 1;
  } else {
    // Add new product
    cart.push({ id: productId, quantity: 1 });
  }

  // Save updated cart back in cookies
  res.cookie("cart", cart);

  return res.redirect("/totalshops");
});


routers.post("/update-cart/:id", (req, res) => {
  const productId = req.params.id;
  const action = req.body.action;  // Get action from the form button

  let cart = req.cookies.cart || [];

  const productIndex = cart.findIndex((item) => item.id === productId);

  if (productIndex > -1) {
    if (action === "increment") {
      cart[productIndex].quantity += 1;
    }
    else if (action === "decrement") {
      // Decrement the quantity
      if (cart[productIndex].quantity > 1) {
        cart[productIndex].quantity -= 1;
      } else {
        // If quantity is 1 and decrement is clicked, remove the product from cart
        cart = cart.filter(item => item.id !== productId);
      }
    }
  }

  res.cookie("cart", cart);
  return res.redirect("/cart");
});


routers.get("/remove-from-cart/:productId", (req, res) => {
  const productId = req.params.productId;
  let cart = req.cookies.cart || [];

  // Remove the product from cart
  cart = cart.filter(item => item.id !== productId);

  res.cookie("cart", cart);
  return res.redirect("/cart");
});


routers.get('/checkout', async (req, res) => {
  const cart = req.cookies.cart || [];

  if (cart.length === 0) {
    return res.render('checkout', { products: [], total: '0.00' });
  }

  const productIds = cart.map(item => item.id);

  const productsFromDb = await Product.find({ _id: { $in: productIds } })
    .populate('shopId')
    .populate('category');

  const products = productsFromDb.map(product => {
    const cartItem = cart.find(item => item.id === product._id.toString());
    return {
      ...product.toObject(),
      quantity: cartItem ? cartItem.quantity : 1
    };
  });

  const total = products.reduce((sum, p) => sum + (p.price * p.quantity), 0);

  res.render('checkout', { products, total: total.toFixed(2) });
});

module.exports=routers;