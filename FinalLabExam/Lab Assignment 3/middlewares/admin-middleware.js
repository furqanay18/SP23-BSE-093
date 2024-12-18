module.exports = async function (req, res, next) {
  // Check if user is logged in and has the admin role
  if (!req.session.user || !req.session.user.role || !req.session.user.role.includes("admin")) {
    console.log("Unauthorized Access: User does not have admin role.");
    return res.status(403).send(`
      <h3>403 Forbidden</h3>
      <p>You do not have permission to access this page.</p>
      <a href="/">Go to Home</a>
    `);
  }
  next(); // User is admin, proceed
};
