const express = require("express");
const Product = require("../models/product-model");
const Category = require("../models/categories-model");
const multer = require("multer");
const mongoose = require("mongoose");
mongoose.set('strictPopulate', false);
const path = require("path");
const cookieParser = require("cookie-parser");



// Middleware
const isAuthenticated = require("../middlewares/auth-middleware");

const router = express.Router();
// Use cookie-parser middleware
router.use(cookieParser());
// Set up Multer storage engine
const storage =  multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/'); // Save images in 'uploads' folder
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + path.extname(file.originalname)); // Timestamp the filename to prevent conflicts
    }
  });
  
  const upload = multer({ storage: storage });
  // Route to view all products (GET) with categories, search, and sorting functionality
const isAdmin = require("../middlewares/admin-middleware");

// Route to display all products in the admin panel
router.get("/adminpanel",isAdmin, async (req, res) => {
  try {
    const products = await Product.find();
    const category = await Category.find();
    res.render("adminpanel", { products, category });
  } catch (error) {
    console.error(error);
    res.status(500).send("Error fetching data.");
  }
});



router.get("/shopnow", async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1; // Default to page 1 if no page is specified
      const limit = 5; // Number of products per page
      const skip = (page - 1) * limit;
      const searchQuery = req.query.search || "";
      const categoryFilter = req.query.category || ""; // Get the category filter from the query parameters
      const sortQuery = req.query.sort || ""; // Get the sort query parameter
  
      // Construct filter object for search and category
      const filter = {};
      if (searchQuery) {
        filter.name = { $regex: searchQuery, $options: "i" }; // Case-insensitive search by name
      }
  
      if (categoryFilter) {
        // Find the category by title to get its _id
        const category = await Category.findOne({ title: categoryFilter });
        if (category) {
          filter.categoryId = category._id; // Match categoryId in products
        } else {
          console.log(`No category found for title: ${categoryFilter}`);
        }
      }
  
      // Determine the sorting order
      let sort = {};
      if (sortQuery === "priceLow") {
        sort.price = 1; // Price Low to High
      } else if (sortQuery === "priceHigh") {
        sort.price = -1; // Price High to Low
      } else if (sortQuery === "asc") {
        sort.name = 1; // Alphabetical A to Z
      } else if (sortQuery === "desc") {
        sort.name = -1; // Alphabetical Z to A
      }
  
      // Fetch products based on the filter and sort criteria
      const products = await Product.find(filter)
        .populate("categoryId", "title") // Populate category details
        .skip(skip)
        .limit(limit)
        .sort(sort);
  
      // Get total count for pagination
      const totalCount = await Product.countDocuments(filter);
      const totalPages = Math.ceil(totalCount / limit);
  
      // Fetch all categories for the category filter dropdown
      const categories = await Category.find();
  
      res.render("shopnow", {
        pageTitle: "Shop Now",
        products,
        currentPage: page,
        totalPages,
        searchQuery,
        categories, // Pass categories to the view for the filter dropdown
        selectedCategory: categoryFilter, // Keep track of selected category
        selectedSort: sortQuery, // Keep track of selected sort option
      });
    } catch (err) {
      console.error("Error fetching products:", err);
      res.status(500).send("Error fetching products");
    }
  });
  
router.post("/shopnow/add-to-cart/:id",isAuthenticated, (req, res) => {
    const productId = req.params.id; // Get the product ID from the URL
  
    // Retrieve the cart from cookies, or initialize it as an empty array
    let cart = req.cookies.cart || [];
  
    // Add the product ID to the cart if it's not already present
    if (!cart.includes(productId)) {
      cart.push(productId);
    }
  
    // Set the updated cart back into cookies
    res.cookie("cart", cart);
  
    console.log("Cart after adding product:", cart); // Debugging step
    res.redirect("/shopnow"); // Redirect to the cart page
  });
  
  /*
  router.post("/cart/remove/:id",isAuthenticated, (req, res) => {
    const productId = req.params.id; // Get the product ID from the URL
  
    // Retrieve the cart from cookies, or initialize it as an empty array
    let cart = req.cookies.cart || [];
  
    // Filter out the product ID to remove it from the cart
    cart = cart.filter(id => id !== productId);
  
    // Update the cart cookie
    res.cookie("cart", cart);
  
    console.log("Cart after removing product:", cart); // Debugging step
    res.redirect("/cart"); // Redirect back to the cart page
  });
  
  */
  
  
  router.get("/cart",isAuthenticated, async (req, res) => {
    let cart = req.cookies.cart || []; // Retrieve the cart from cookies, default to empty array
  
    // Validate MongoDB ObjectIDs to prevent invalid queries
    const validCart = cart.filter(id => mongoose.isValidObjectId(id));
  
    try {
      // Fetch the products corresponding to the IDs in the cart
      const products = await Product.find({ _id: { $in: validCart } });
  
      console.log("Products in cart:", products); // Debugging step
      return res.render("cart", { products, message: null });
    } catch (err) {
      console.error("Error fetching cart products:", err.message);
      return res.status(500).send("Internal router Error");
    }
  });
  
  // Checkout route
  router.get("/checkout", isAuthenticated, (req, res) => {
    // Get cart items from cookies
    let cart = req.cookies.cart || [];
  
    // If cart is empty, redirect to the cart page
    if (cart.length === 0) {
      return res.redirect("/cart");
    }
  
    // Fetch the products in the cart from the database
    Product.find({ _id: { $in: cart } })
      .then((products) => {
        // Render checkout page and pass products
        res.render("checkout", { products });
      })
      .catch((err) => {
        console.error("Error fetching products:", err);
        res.status(500).send("Internal router Error");
      });
  });
  
  // POST: Handle Order Submission
  router.post("/order", isAuthenticated, async (req, res) => {
    const { address, phoneNumber } = req.body;
    const cart = req.cookies.cart || [];
  
    if (!cart.length) {
      req.flash("error", "Your cart is empty.");
      return res.redirect("/cart");
    }
  
    try {
      // Validate MongoDB ObjectIDs
      const validCart = cart.filter(id => mongoose.isValidObjectId(id));
      console.log("Valid Cart:", validCart);
  
      // Fetch products
      const productsInCart = await Product.find({ _id: { $in: validCart } });
      console.log("Products in Cart:", productsInCart);
  
      let totalAmount = 0;
  
      const orderProducts = productsInCart.map(product => {
        const quantity = cart.filter(id => id.toString() === product._id.toString()).length;
  
  
        totalAmount += product.price * quantity;
  
        return {
          productId: product._id,
          quantity: quantity,
          price: product.price
        };
      });
  
  
      const newOrder = new Order({
        customerId: req.session.user._id,
        products: orderProducts,
        totalAmount: totalAmount,
        shippingAddress: address,
        paymentMethod: "Cash on Delivery",
        status: "Pending",
        datePlaced: Date.now()
      });
  
      await newOrder.save();
      res.clearCookie("cart");
      req.flash("success", "Your order has been placed successfully!");
      res.redirect("/confirmation");
    } catch (err) {
      console.error("Error placing the order:", err.message);
      req.flash("error", "Something went wrong while processing your order. Please try again.");
      res.redirect("/cart");
    }
  });
  
  
  
  // GET: Order Confirmation Page (optional)
  router.get("/confirmation", (req, res) => {
    res.render("Confirmation"); // Render a confirmation view
  });
  

// Route to display the form to create a new product
router.get("/adminpanel/CreateProduct", (req, res) => {
  res.render("createProduct");
});

// Route to handle the creation of a new product
router.post("/adminpanel/CreateProduct", upload.single("image"), async (req, res) => {
  try {
    const { name, price, material, dimensions, category } = req.body;
    const image = req.file ? `/uploads/${req.file.filename}` : null;

    const newProduct = new Product({
      name,
      price,
      material,
      dimensions,
      category,
      image,
    });
    await newProduct.save();
    res.redirect("/adminpanel");
  } catch (error) {
    console.error(error);
    res.status(500).send("Error creating product.");
  }
});

// Route to edit a product
router.get("/adminpanel/products-edit/:id", async (req, res) => {
  const id = req.params.id;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).send("Invalid product ID.");
  }

  try {
    const product = await Product.findById(id);
    if (!product) {
      return res.status(404).send("Product not found.");
    }
    res.render("product-edit-form", { product });
  } catch (error) {
    console.error(error);
    res.status(500).send("Error fetching product details.");
  }
});

// Route to update a product
router.post("/adminpanel/products-edit/:id", async (req, res) => {
  try {
    const productId = req.params.id;
    const updatedData = req.body;
    await Product.findByIdAndUpdate(productId, updatedData);
    res.redirect("/adminpanel");
  } catch (error) {
    console.error(error);
    res.status(500).send("Error updating product.");
  }
});
// Route to delete a product
router.get("/adminpanel/products-delete/:id", async (req, res) => {
    try {
      await Product.findByIdAndDelete(req.params.id);
      res.redirect("/adminpanel");
    } catch (err) {
      console.error("Error deleting product:", err);
      res.status(500).send("Error deleting product");
    }
  });



module.exports = router;