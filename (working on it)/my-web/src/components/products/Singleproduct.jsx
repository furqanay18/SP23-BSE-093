import React from "react";

const SingleProduct = ({ product }) => {
    if (!product) return <p>No product found</p>;

    return (
        <div style={{ border: "1px solid #ccc", padding: "10px", margin: "10px" }}>
            <h3>{product.name}</h3>
            <p>Price: ${product.price}</p>
        </div>
    );
};

export default SingleProduct;
