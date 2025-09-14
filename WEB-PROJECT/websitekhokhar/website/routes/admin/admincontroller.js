// routes/admin/admincontroller.js
const express = require('express');
const router = express.Router();
const Shop = require('../../models/shopmodel');

// Middleware for admin auth (dummy for now)
function adminAuth(req, res, next) {
  // TODO: Replace with real admin authentication
  next();
}

// GET: Admin simple panel
router.get("/adminpanel", async (req, res) => {
  return res.render("adminpanel");
});

// GET: View pending shops
router.get('/shopsdata', adminAuth, async (req, res) => {
  try {
    const newshop = await Shop.find({ status: 'pending' });
    res.render('shopsdata', { newshop: newshop });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});



router.get('/totalshops', adminAuth, async (req, res) => {
  try {
    const totalApprovedShops = await Shop.find({ status: 'approved', isPaid: true });
    res.render('totalshops', { shops: totalApprovedShops });
  } catch (error) {
    console.error(error);
    res.status(500).send('Failed to fetch total approved shops');
  }
});

// POST: Approve shop
router.post('/admin/approve-shop/:id', adminAuth, async (req, res) => {
  try {
    await Shop.findByIdAndUpdate(req.params.id, {
      status: 'approved',
      isPaid: true
    });
    // Redirect to total shops page instead of shopsdata
    res.redirect('/adminpanel');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error approving shop');
  }
});


// POST: Reject shop
router.post('/admin/reject-shop/:id', adminAuth, async (req, res) => {
  try {
    await Shop.findByIdAndUpdate(req.params.id, {
      status: 'rejected'
    });
    res.redirect('/shopsdata');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error rejecting shop');
  }
});

router.get("/admin/dashboard", async(req,res)=>{
  return res.redirect("/adminpanel");
});


router.get("/admin/logout", async(req,res)=>{
  return res.redirect("/");
})
module.exports = router;
