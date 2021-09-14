import React, { Component } from "react";
import SimpleStorageContract from "./contracts/FoodSupply.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class Buyer extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = SimpleStorageContract.networks[networkId];
      const instance = new web3.eth.Contract(
        SimpleStorageContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  buyPro = async () => {
    const {accounts, contract } = this.state;

    const _id = document.getElementById("pid").value;
    const _ether = document.getElementById("ether").value;

    await contract.methods.buy(_id).send({ from: accounts[0],value: _ether*10**18 });

    const prod = await contract.methods.getDetails(_id).call();
    const{0:name, 1:details, 2:price, 3:totalPrice, 4:seller, 5:buyer, 6:review} = prod;

    // Update state with the result.
    this.setState( {storageValue: [name, details, price, totalPrice, seller, buyer, review] });
  };


  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Agriculture Food Supply Chain Management Using Blockchain</h1>
        <p><b>Buyer Page</b></p>
        <div className="buy">
          <table>
          <tr><td>Enter Product ID : </td><td></td><td><input type="text" id = "pid" placeholder="Enter Product ID"></input></td></tr><br></br>
          <tr><td>Enter Ethereum : </td><td></td><td><input type="number" id = "ether" placeholder="Enter Ethereum"></input></td></tr><br></br>
          </table>
        <button type="submit" className="btn" onClick={this.buyPro}>Buy Product & Display Details</button>
        </div>
        <div>
        <br></br><h2>PRODUCT DETAILS : </h2>
          <ul>
            <li>Product Name : {this.state.storageValue[0]}</li><br />
            <li>Product Description : {this.state.storageValue[1]}</li><br />
            <li>Product Price : {this.state.storageValue[2]}</li><br />
            <li>Product TotalPrice : {this.state.storageValue[3]}</li><br />
            <li>Seller Address : {this.state.storageValue[4]}</li><br />
            <li>Buyer Address : {this.state.storageValue[5]}</li><br />
            <li>Review by Buyer : {this.state.storageValue[6]}</li><br />
          </ul>
        </div>
        <div>
          <button type="submit" className="btn1">Delivery</button>
          <button type="submit" className="btn1">Refund</button>
        </div>
     </div>
    );
  }
}

export default Buyer;
