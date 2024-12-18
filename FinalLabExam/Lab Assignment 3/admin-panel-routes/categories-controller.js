const express = require('express');
const Category = require('../models/categories-model'); // Adjust path if needed
const mongoose = require('mongoose');

const router = express.Router();



// Route to display the form to create a new product
router.get('/adminpanel/CreateCategory', (req, res) => {
    res.render('createCategory');
});

router.post('/adminpanel/CreateCategory', async (req, res) => {
    try {
        const data = req.body;
        console.log('Category Data:', data); // Log to check what data is being sent
        let newCategory = new Category(data);
        await newCategory.save();
        res.redirect('/adminpanel');
    } catch (error) {
        console.error('Error saving category:', error);
        res.status(500).send('Server error');
    }
});

// Route to edit a product
router.get('/adminpanel/category-edit/:id', async (req, res) => {
    const id = req.params.id;
    if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).send('Invalid product ID');
    }

    try {
        let category = await Category.findById(id);
        if (!category) {
            return res.status(404).send('Product not found');
        }
        res.render('category-edit-form', { category });
    } catch (error) {
        res.status(500).send('Server error');
    }
});

// Route to update a product
router.post('/adminpanel/category-edit/:id', async (req, res) => {
    try {
        const ID = req.params.id;
        const updatedData = req.body;
        await Category.findByIdAndUpdate(ID, updatedData);
        res.redirect('/adminpanel');
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
});

router.get("/admin/categories-delete/:id" , async (req,res)=> {
    let params = req.params;
    let category  = await Category.findByIdAndDelete(req.params.id);
    return res.redirect("/adminpanel");
});

module.exports = router;
