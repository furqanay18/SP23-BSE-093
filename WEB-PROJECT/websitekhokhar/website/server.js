require('dotenv').config();

const express = require("express");
const mongoose = require("mongoose");
const multer = require('multer');


const server = express();

let cookieParser = require("cookie-parser");
server.use(cookieParser());

let session = require("express-session");
server.use(session({ secret: "my session secret" }));

// View engine setup
server.set("view engine", "ejs");
server.use(express.static("public"));
server.use(express.static("uploads"));
server.use("/uploads", express.static("uploads"));

// Body parsers
server.use(express.urlencoded({ extended: true }));
server.use(express.json());

// MongoDB connection
const connectionString = process.env.MONGODB_URI || "mongodb://127.0.0.1/website";
mongoose.connect(connectionString)
  .then(() => console.log("✅ Connected to MongoDB"))
  .catch((error) => console.error("❌ MongoDB Error:", error.message));

// Multer file upload config
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads");
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage: storage });

// Models
const Shop = require("./models/shopmodel");
const Category =require("./models/categorymodel");
// Admin routes
const adminProductsRouter = require("./routes/admin/productscontroller");
server.use(adminProductsRouter);

const orderroute = require("./routes/shop/ordercontroller");
server.use(orderroute);


const cartcontroller = require("./routes/shop/cartcontroller");
server.use(cartcontroller);

const adminController = require('./routes/admin/admincontroller');
server.use(adminController);

const shopcontroller=require("./routes/shop/shopcontroller");
server.use(shopcontroller);

const ridercontroller=require("./routes/shop/ridercontroller");
server.use(ridercontroller);



// Home page route
server.get("/", async (req, res) => {
  const Product = require("./models/productsmodel");
  const products = await Product.find();
  const categories = await Category.find();
  res.render("landingpage", { products, categories});
});

// GET: Render registration form
server.get("/register", (req, res) => {
  res.render("register");
});

// POST: Handle shop registration & Safepay session
server.post(
  '/register',
  upload.fields([
    { name: 'logo', maxCount: 1 },
    { name: 'pictures' },
    { name: 'banners' },
    { name: 'payment_screenshot', maxCount: 1 }
  ]),
  async (req, res) => {
    const { name, address,city, email, phone, password, transaction_id } = req.body;

    try {
      // Extract just the filenames (not full paths)
      const logo = req.files.logo?.[0]?.filename;
      const pictures = req.files.pictures?.map(file => file.filename) || [];
      const banners = req.files.banners?.map(file => file.filename) || [];
      const payment_screenshot = req.files.payment_screenshot?.[0]?.filename;

      const newshop = new Shop({
        name,
        address,
        city,
        email,
        phone,
        password,
        logo,
        pictures,
        banners,
        transaction_id,
        payment_screenshot,
        isPaid: false,
        status: 'pending'
      });

      await newshop.save();

      res.render("success");
    } catch (error) {
      console.error("❌ Registration error:", error);
      res.status(500).send("Server error during registration.");
    }
  }
);

// GET: Success Page
server.get("/success", (req, res) => {
  res.render("success", { message: "✅ Registration successful!" });
});

// Login GET
server.get("/login", (req, res) => {
  res.render("login");
});

// Login POST
server.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const existingShop = await Shop.findOne({ email });

    if (!existingShop) return res.status(400).send("Shop not found.");
    if (existingShop.password !== password) return res.status(401).send("Invalid password.");
    if (existingShop.status !== 'approved') return res.status(403).send("Awaiting admin approval.");

    // ✅ Store shop ID in session
    req.session.shopId = existingShop._id;

    // ✅ Render shop page
    res.render("shoppage", { shop: existingShop ,isOwner: true });
  } catch (error) {
    console.error("❌ Login error:", error);
    res.status(500).send("Server error.");
  }
}); 

server.get('/rider', (req, res) => {
  res.render('riderDashboard'); // render riderPortal.ejs
});


// Start server
server.listen(1400, () => {
  console.log(" Server started at http://localhost:8000");
});


