const mongoose = require("mongoose");

// Define the product schema
let productSchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100, // Limit product name length
  },
  price: {
    type: Number,
    required: true,
    min: 0, // Ensure price cannot be negative
  },
  material: {
    type: String,
    trim: true,
    default: "Unknown", // Default material if not provided
  },
  dimensions: {
    type: String,
    trim: true,
    match: /^\d+x\d+x\d+$/, // Ensure format like "50x40x30"
    default: "Not specified",
  },
  category: {
    type: String,
    required: true,
    enum: [
      "Living Room",
      "Bedroom",
      "Dining Room",
      "Office Furniture",
      "Outdoor Furniture",
    ],
    default: "Living Room", // Default to "Living Room"
  },
  image: {
    type: String, // Path or URL to the uploaded image
    default: null, // Default value if no image is uploaded
  },
});

// Create the Product model
let ProductModel = mongoose.model("Product", productSchema);

module.exports = ProductModel;
