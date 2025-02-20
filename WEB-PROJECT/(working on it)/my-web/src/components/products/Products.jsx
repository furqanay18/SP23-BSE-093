import React from "react";
import SingleProduct from "./Singleproduct"; // Ensure file name is correct

const Products = () => {
    const [products, setProducts] = React.useState([
        { name: "abc", price: 400 },
        { name: "abcd", price: 4300 }
    ]);

    console.log("Products State:", products); // Debugging

    return ( 
        <div>
            <h1>Products</h1>
            {products.length > 0 ? (
                products.map((product, index) => (
                    <SingleProduct key={index} product={product} />
                ))
            ) : (
                <p>No products available</p>
            )}
        </div> 
    );
};

export default Products;

