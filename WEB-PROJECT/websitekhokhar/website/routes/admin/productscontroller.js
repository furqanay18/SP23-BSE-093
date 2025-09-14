const express = require("express");
let router = express.Router();
let multer = require("multer");
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads"); // Directory to store files
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`); // Unique file name
  },
});
const upload = multer({ storage: storage });
let Product = require("../../models/productsmodel");
let Category = require("../../models/categorymodel");
let Order=require("../../models/ordermodel");

router.get("/admin/products/delete/:id", async (req, res) => {
  const product = await Product.findById(req.params.id);

  // ✅ Confirm ownership before deletion
  if (!product || product.shopId.toString() !== req.session.shopId) {
    return res.status(403).send("Unauthorized access");
  }

  await Product.findByIdAndDelete(req.params.id);
  return res.redirect("/admin/products");
});

router.get("/admin/products/create", async (req, res) => {
  try {
    const categories = await Category.find(); // fetch all categories from DB
    res.render("admin/createproduct", {
      layout: "adminlayout",
      pageTitle: "Create New Product",
      categories: categories // pass categories to EJS
    });
  } catch (err) {
    console.error("Error fetching categories:", err);
    res.status(500).send("Internal Server Error");
  }
});

router.post("/admin/products/create", upload.single("file"), async (req, res) => {
  try {
    const shopId = req.session.shopId;

    if (!shopId) {
      return res.status(401).send("Unauthorized: Shop not logged in");
    }

    const { title, description, price,stock, category } = req.body;

    // Optional: Validate required fields
    if (!title || !price || !stock || !category) {
      return res.status(400).send("Missing required fields");
    }

    const newProduct = new Product({
      title,
      description,
      price,
      stock,
      category, // ✅ User manually enters this in the form
      picture: req.file ? req.file.filename : null,
      shopId
    });

    await newProduct.save();
    return res.redirect("/admin/products");

  } catch (error) {
    console.error("❌ Error creating product:", error);
    res.status(500).send("Server error");
  }
});



router.get('/productspage', async (req, res) => {
  try {
      const products = await Product.find(); // Fetch all products from the database
      res.render('productspage', { products }); // Pass products to EJS
  } catch (error) {
      console.error('Error fetching products:', error);
      res.status(500).send('Server error');
  }
});

// GET: Show edit form
router.get("/admin/products/edit/:id", async (req, res) => {
  const product = await Product.findById(req.params.id);

  // ✅ Only allow access if product belongs to logged-in shop
  if (!product || product.shopId.toString() !== req.session.shopId) {
    return res.status(403).send("Unauthorized access");
  }

  const categories = await Category.find(); // Fetch all categories

  return res.render("admin/editproduct", {
    product,
    categories,
  });
});

router.post("/admin/products/edit/:id", upload.single("file"), async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product || product.shopId.toString() !== req.session.shopId) {
    return res.status(403).send("Unauthorized access");
  }

  product.title = req.body.title;
  product.description = req.body.description;
  product.price = req.body.price;
  product.category = req.body.category;

  if (req.file) {
    product.picture = req.file.filename; // ✅ Replace old image
  }

  await product.save();
  return res.redirect("/admin/products");
});




router.get("/admin/products", async (req, res) => {
  try {
    const shopId = req.session.shopId;

    if (!shopId) {
      return res.status(401).send("Unauthorized: Shop not logged in");
    }

    const totalOrders = await Order.countDocuments({ shopId });


    const newOrdersCount = await Order.countDocuments({
      shopId,
      status: 'pending',
      deliveryStatus: 'not_assigned'
    });

    const deliveredOrders = await Order.find({
      shopId,
      status: 'delivered'
    });

    const totalSales = deliveredOrders.reduce((sum, order) => sum + order.totalAmount, 0);

    const pendingShipmentsCount = await Order.countDocuments({
  shopId,
  status: { $in: ['pending', 'shipped'] },
  deliveryStatus: { $in: ['assigned', 'picked_up'] }
});

    // Assuming 'category' is a reference (ObjectId) to a Category model
    const products = await Product.find({ shopId }).populate("category");

    res.render("admin/products", { products,totalOrders ,newOrdersCount,totalSales,pendingShipmentsCount});
  } catch (error) {
    console.error("❌ Product fetch error:", error);
    res.status(500).send("Server error");
  }
});





// GET /products - Show products filtered by category
router.get('/category/products', async (req, res) => {
  const categoryId = req.query.category;
  try {
    let products;

    if (!categoryId || categoryId === 'all') {
      products = await Product.find();
    } else {
      products = await Product.find({ category: categoryId });
    }

    res.render('categoryproducts', { products });
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});



module.exports = router;