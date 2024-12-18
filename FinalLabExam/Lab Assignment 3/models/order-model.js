const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Define the schema for orders, outlining all required fields and their relationships

const OrderSchema = new Schema({
    // Reference to the customer placing the order, linked to the User model
    customerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User", // Assuming a User model exists for customers
        required: true // Ensures every order has a valid customer ID
    },
    
    // Array of products in the order, including their ID, quantity, and price
    products: [{
        productId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product', // Links to the Product model for detailed product info
            required: true // Ensures each product entry has a valid product ID
        },
        quantity: {
            type: Number,
            required: true // The quantity of each product must be specified
        },
        price: {
            type: Number,
            required: true // Price per unit of the product must be specified
        }
    }],

    // The total amount for the order, calculated from all products
    totalAmount: {
        type: Number,
        required: true // Ensures the total order amount is always stored
    },

    // Shipping address for the order delivery
    shippingAddress: {
        type: String,
        required: true // Ensures an address is provided for every order
    },

    // Payment method used for the order; defaults to 'Cash on Delivery'
    paymentMethod: {
        type: String,
        default: 'Cash on Delivery', // Default value for payment method
        required: true // Ensures every order has a payment method specified
    },

    // Current status of the order, can be 'Pending', 'Shipped', or 'Delivered'
    status: {
        type: String,
        enum: ['Pending', 'Shipped', 'Delivered'], // Allowed values for status
        default: 'Pending', // Initial status when the order is created
        required: true // Ensures every order has a valid status
    },

    // Date and time when the order was placed
    datePlaced: {
        type: Date,
        default: Date.now // Automatically records the order placement timestamp
    }
});

// Create the Order model using the defined schema
const Order = mongoose.model('Order', OrderSchema);

// Export the model for use in other parts of the application
module.exports = Order;
