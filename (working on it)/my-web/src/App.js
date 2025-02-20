import React from "react";
import { BrowserRouter as Router, Route, Routes, Navigate } from "react-router-dom";
import Sidebar from "./components/Sidebar";
import Landingpage from "./components/Landingpage"; // Ensure correct import name
import Products from "./components/products/Products";
import Contactus from "./components/Contactus";
import NotFound from "./components/NotFound"; // Import the NotFound component
function App() {
  return (
    <Router>
      <div>
        <Sidebar />
        <Routes>
          <Route path="/" element={<Landingpage />} />
          <Route path="/products" element={<Products />} />
          <Route path="/contactus" element={<Contactus />} />
          <Route path="/not" element={<NotFound/>} />
          <Route path="*" element={<Navigate to="/not" />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
