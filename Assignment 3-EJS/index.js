const express =require ('express');
let server=express();

server.set("view engine","ejs");
server.use(express.static("public"))
server.get("/",(req,res)=>{
    res.render("page");
});

server.get("/portfolio", (req,res) =>{
    res.render("portfolio")
});

server.listen(5020, () => {
    console.log("server Started at localhost:5020");
})



