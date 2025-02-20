import React from "react";
import { Link } from "react-router-dom";
import AppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
const styles={
  link:{
    padding:"1rem"
  }
}


const Sidebar = () => {
  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6">
          <Link to="/" style={styles.link}>Home</Link>
        </Typography>
        <Typography variant="h6">
          <Link to="/products" style={styles.link}>Products</Link>
        </Typography >
        <Typography variant="h6">
          <Link to="/services" >Services</Link>
        </Typography>
        <Typography variant="h6">
          <Link to="/contactus" style={styles.link}>Contact</Link>
        </Typography>
      </Toolbar>
    </AppBar>
  );
};

export default Sidebar;
