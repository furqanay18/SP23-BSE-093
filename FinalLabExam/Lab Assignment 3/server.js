// Importing required modules
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const session = require("express-session");
const expressLayouts = require("express-ejs-layouts");
const flash = require("connect-flash");
const cookieParser = require('cookie-parser');
const productRoutes = require("./admin-panel-routes/product-controller");
const categoryRoutes = require("./admin-panel-routes/categories-controller");
const siteMiddleware = require("./middlewares/site-middleware");
const UserModel = require("./models/user-model");

const app = express();

// Set up EJS as the view engine
app.set("view engine", "ejs");

// Middleware for serving static files (e.g., images, CSS, JavaScript)
app.use(express.static("public"));
app.use("/uploads", express.static("uploads"));

// Middleware to parse URL-encoded data (for form submissions)
app.use(express.urlencoded({ extended: true }));

// Session middleware setup
app.use(session({
  secret: 'your-secret-key',  // Secret to sign session ID cookie
  resave: false,              // Don't save session if unmodified
  saveUninitialized: false,   // Don't save empty sessions
  cookie: { maxAge: 1000 * 60 * 15 } // Session expires in 15 minutes
}));

// Middleware to add user data to local variables for easier access in views
app.use(async (req, res, next) => {
  console.log("Session Data:", req.session); // Debugging: Log session data
  res.locals.isLoggedIn = req.session.user ? true : false; // Check if user is logged in
  res.locals.user = req.session.user || null;  // Add user data if logged in, otherwise null
  next();
});

// Configure connect-flash middleware for flash messages
app.use(flash());

// Middleware to make flash messages available in views
app.use((req, res, next) => {
  res.locals.success_msg = req.flash("success");
  res.locals.error_msg = req.flash("error");
  next();
});

// Home route with session check
app.get("/", (req, res) => {
  if (req.session.user) {
    res.render('web', { user: req.session.user });  // Render web page if user is logged in
  } else {
    req.flash("error", "You must be logged in to access this page. Please log in to continue.");
    res.redirect('/login'); // Redirect to login if user is not authenticated
  }
});

// Custom middleware for other site functionalities (defined elsewhere in your project)
app.use(siteMiddleware);

// Define routes for product and category management
app.use(productRoutes);
app.use(categoryRoutes);

// GET: Login Page
app.get("/login", (req, res) => {
  res.render("auth/login");  // Render login page
});

// POST: Login Route
app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  console.log("Login Attempt:", email); // Debugging: Log login attempt

  try {
    const user = await UserModel.findOne({ email });  // Find user by email
    if (user) {
      const isMatch = await bcrypt.compare(password, user.password);  // Compare password
      if (isMatch) {
        req.session.user = user;  // Store user in session if credentials match
        req.flash("success", `Welcome back, ${user.name}! You have successfully logged in.`);
        return res.redirect("/");  // Redirect to home page
      }
    }
    // Flash message with longer description
    req.flash("error", "The credentials you entered are incorrect. Please double-check your email and password and try again.");
    res.redirect("/login");  // Redirect to login page
  } catch (error) {
    console.error("Error during login:", error.message);
    req.flash("error", "An error occurred while processing your login request. Please try again later.");
    res.redirect("/login");
  }
});

// GET: Register Page
app.get("/register", (req, res) => {
  res.render("auth/register");  // Render registration page
});

// POST: Register Route
app.post("/register", async (req, res) => {
  const { name, email, password } = req.body;
  console.log("Registration Attempt:", email); // Debugging: Log registration attempt

  try {
    const existingUser = await UserModel.findOne({ email });  // Check if user already exists
    if (existingUser) {
      // Flash message with more details
      req.flash("error", "A user with this email address already exists. Please try logging in or use a different email address to register.");
      return res.redirect("/register");
    }

    const salt = await bcrypt.genSalt(10);  // Generate salt for password hashing
    const hashedPassword = await bcrypt.hash(password, salt);  // Hash password

    const newUser = new UserModel({
      name,
      email,
      password: hashedPassword,  // Save hashed password
    });

    await newUser.save();  // Save new user in database

    req.flash("success", "Your registration was successful! You can now log in using your new account. Welcome to our platform!");
    res.redirect("/login");  // Redirect to login page
  } catch (error) {
    console.error("Error during registration:", error.message);
    req.flash("error", "We encountered an issue while processing your registration. Please try again later.");
    res.redirect("/register");
  }
});

// GET: Logout
app.get("/logout", (req, res) => {
  console.log("LOGGING OUT...");
  req.session.destroy((err) => {  // Destroy the session
    if (err) {
      console.error("Error logging out:", err);
      return res.send("We were unable to log you out at this time. Please try again later.");
    }
    res.clearCookie("cart");  // Clear the cart cookie
    res.clearCookie("connect.sid");  // Clear the session cookie
    req.flash("success", "You have successfully logged out. Come back soon!");
    res.redirect("/");  // Redirect to home page after logout
  });
});

// MongoDB connection setup
const connectionString = "mongodb://localhost/interiordesign";
mongoose
  .connect(connectionString, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log(`Connected to MongoDB: ${connectionString}`))  // Log success
  .catch((error) => console.error("Database Connection Error:", error.message));  // Handle connection errors

// Start the app on port 5020
app.listen(5020, () => console.log("App started at http://localhost:5020"));
