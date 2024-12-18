const mongoose = require("mongoose");

// Define the product schema
let CategorySchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100, // Limit product name length
  }
});

// Create the Product model
let CategoriesModel = mongoose.model("Category", CategorySchema);

module.exports = CategoriesModel;