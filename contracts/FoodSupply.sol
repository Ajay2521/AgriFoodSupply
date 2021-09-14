// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

// product registration.
// buyer buys the product.
// buyer confirms delivery so money will be transferred to the seller

contract FoodSupply{

  uint counter = 1; // for productId

  struct Product{
    string name;
    string details;
    address payable seller;
    uint productId;
    uint price; // in wel
    uint quantity; // in kgs
    uint totalPrice;
    address payable buyer;
    address preseller;
    bool delivered;
    string review;
  }

  Product[] public products;

  // events.
  event registered(string name, uint productId, uint totalPrice, address seller);
  event bought(uint productId, address buyer);
  event delivered(uint productId, address buyer,string review);
  event refunded(uint productId,address buyer, string review);
  
  // creating function registerProduct - to product registration.
  function registerProduct(string memory _name, string memory _details, uint _price, uint _quantity) public{

    require(_price > 0, "Price should be greater than 0.");
    // enter product details inculding who is seller
    Product memory newProduct;
    newProduct.name = _name;
    newProduct.details = _details;
    newProduct.price = _price * 10**18; // converting wels to ether
    newProduct.quantity = _quantity;
    newProduct.totalPrice = newProduct.price * newProduct.quantity;
    newProduct.seller = msg.sender;
    newProduct.productId = counter;
    products.push(newProduct);
    counter++;

    emit registered(_name, newProduct.productId, newProduct.totalPrice, msg.sender);
  }

  // creating function getBalance -  to display the current balance in the contract 
  function getDetails(uint _productId) public view returns (string memory, string memory, uint, uint, address, address, string memory){
    return  (products[_productId - 1].name, products[_productId - 1].details, products[_productId - 1].price, products[_productId - 1].totalPrice, products[_productId - 1].seller, products[_productId - 1].buyer, products[_productId - 1].review);
  }

  // creating function buy - for buyer buys the product.
  function buy(uint _productId) payable public{

    // seller cannot buy his/her own product
    require(products[_productId - 1].seller != msg.sender,"Seller cannot buy his/her own product.");

    // players must invest astleast 1 ether
    require(products[_productId - 1].totalPrice == msg.value,"Buyer buy price must be same as the price of seller");

    // once product is delivered then it cannot be buyed again
    require(products[_productId - 1].delivered == false ,"The product have sold already");
    products[_productId - 1].buyer = msg.sender;
    
    emit bought(_productId, msg.sender);
  }

  // creating function delivery - buyer confirms delivery so money will be transferred to the seller
  function delivery(uint _productId, string memory _review) public{

    // buyer can only able to confirm about the product delivery
    require(products[_productId - 1].buyer == msg.sender,"Buyer can only confirm delivery.");

    products[_productId - 1].delivered = true;
    products[_productId - 1].seller.transfer(products[_productId - 1].totalPrice);
    products[_productId - 1].preseller = products[_productId - 1].seller;
    products[_productId - 1].seller = msg.sender;
    products[_productId - 1].buyer = address(0);
    products[_productId - 1].review = _review;
    emit delivered(_productId, msg.sender, _review);

  }
  
  
  // creating function refund - buyer request refund during delivery so money will be transferred back to the buyer
  function refund(uint _productId, string memory _review) public{

    // buyer can only able to confirm about the product delivery
    require(products[_productId - 1].buyer == msg.sender,"Buyer can only request for refund.");
    require(products[_productId - 1].delivered == false ,"The product delivery has been confirmed by Buyer");
    products[_productId - 1].buyer.transfer(products[_productId - 1].totalPrice);
    products[_productId - 1].buyer = address(0);
    products[_productId - 1].review = _review;
    emit refunded(_productId, msg.sender,_review);

  }

  // function for changing reselling it. (optional function)
  function reSell(string memory _name, string memory _details, uint _productId, uint _price) public {

    // price must be gearter than zero
    require(_price > 0,"Price cannot be less than or equal to 0");

    // only rightful owner can sell the product
    require(products[_productId - 1].seller == msg.sender,"Only owner can place sell order");
    require(products[_productId - 1].delivered == false ,"The product has been deliveried already");

    // reselling the product.
    products[_productId - 1].name = _name;
    products[_productId - 1].details = _details;
    products[_productId - 1].price = _price;
    products[_productId - 1].totalPrice = products[_productId - 1].quantity * products[_productId - 1].price; 
    products[_productId - 1].seller = msg.sender;
    products[_productId - 1].delivered = false;
    products[_productId - 1].review = "";
    emit registered(products[_productId - 1].name, _productId, products[_productId - 1].totalPrice, msg.sender);
  }

}