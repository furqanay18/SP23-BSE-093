const express = require("express");
let router = express.Router();
const multer = require('multer');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads"); // Directory to store files
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`); // Unique file name
  },
});
const upload = multer({ storage: storage });
let Shop = require("../../models/shopmodel");
let Product = require("../../models/productsmodel");




router.get("/logout" , async(req,res)=>{
  return res.redirect("/login");
})


router.get("/totalshops" , async(req,res)=>{
  return res.render("totalshops");
});


// Route to view individual shop details by ID
router.get('/shoppage/:id', async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.id);

    if (!shop || shop.status !== 'approved' || !shop.isPaid) {
      return res.status(404).send('Shop not found or not approved.');
    }

    res.render('shoppage', { shop ,isOwner: false});
  } catch (err) {
    console.error('Error fetching shop details:', err);
    res.status(500).send('Internal Server Error');
  }
});


router.get('/shoppage/admin/products', async (req, res) => {
  try {
      const products = await Product.find(); // Fetch all products from the database
      res.render('productspage', { products }); // Pass products to EJS
  } catch (error) {
      console.error('Error fetching products:', error);
      res.status(500).send('Server error');
  }
});
// Route to show products for a specific shop
// Show products by specific shop ID
router.get('/shop/:shopid/products', async (req, res) => {
  try {
    const { shopid } = req.params;

    const shop = await Shop.findById(shopid);
    if (!shop) return res.status(404).send("Shop not found.");

    const products = await Product.find({ shopId: shopid });

    res.render("shopsproducts", { shop, products });
  } catch (error) {
    console.error("❌ Error fetching shop products:", error);
    res.status(500).send("Server error.");
  }
});


router.get("/shoppage",(req,res)=>{
  return res.redirect("/shoppage");
})


module.exports = router;