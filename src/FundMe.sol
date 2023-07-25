// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

//I want to get fund from users, withdraw fund and set a minimum funding value in USD
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// this is the interface filled with empty contracts. By compiling these empty contracts, the ABI for the real contracts are resulted.

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //uint256 public myvalue = 1;
    //uint256 public myvalue_msg;

    address[] private s_funders;
    mapping(address => uint256) private s_addresstoamountfunded;

    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address private immutable ownerAddress;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        //deploy the contract on the blockchain, then before the contract can receive any interaction, the constructor will be excuted once!
        ownerAddress = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getversion() public view returns (uint256) {
        uint256 version;
        // the logic was ABI(address).function(); ABI was obtained through interface compilation.
        return version = s_priceFeed.version();
    }

    modifier onlyOwner() {
        //require(msg.sender == ownerAddress, "fail");
        if (msg.sender != ownerAddress) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function getTheDataFeedVersion() public view returns (uint256) {
        return PriceConverter.getversion();
    }

    function fund() public payable {
        //returns (uint256) {
        //1. allow user to send $
        //2. Have a min $5 sent
        //How do we send ETH to this contract?

        //myvalue = myvalue + 1;

        //require(msg.value > 1e15, "send more");
        //require(getconversionrate(msg.value) > MINIMUM_USD, "send more");

        //whenever using a librbay, the first argument (aka. inout variable) is going ton be the type of using the library.
        // in this example, in PriceConverter library, getconversionrate function is defined as getconversionrate(uint256 ETHAmount).
        //so the type uint256 (in this case msg.value) that used getconversionrate(msg.value) becomes  msg.value.getconversionrate().
        //note! if  getconversionrate is defined as getconversionrate(uint256 ETHAmount, address _address)
        //then the usage of the library would be msg.value.getconversionrate(_address)
        require(
            msg.value.getconversionrate(s_priceFeed) > MINIMUM_USD,
            "send more"
        );

        s_funders.push(msg.sender);

        //mappingInstanceName[key] =  value;
        //the mapping was by default initiated with 0 for any unspecific key. So the first transaction addresstoamountfunded[msg.sender] =0; Hence forrlowing logic can be used
        s_addresstoamountfunded[msg.sender] =
            s_addresstoamountfunded[msg.sender] +
            msg.value;

        //myvalue_msg = msg.value;
        //return myvalue_msg;
    }

    //function getmymsgvalue() internal view returns(uint256){
    //  uint256 mymsgvalue = msg.value;
    //return mymsgvalue;
    //}

    //function getmymsgvalue2() public view returns(uint256){
    //  uint256 myvalue2 = getmymsgvalue();
    //return myvalue2;
    //}

    function withdrawCheaper() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (uint256 index = 0; index < funderLength; index++) {
            s_addresstoamountfunded[address(s_funders[index])] = 0;
        }
        s_funders = new address[](0);
        payable(msg.sender).transfer(address(this).balance);
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "send failed");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == ownerAddress, "must be owner");
        //first clear up the funder's array
        for (uint Index = 0; Index < s_funders.length; Index++) {
            address funder = s_funders[Index];
            s_addresstoamountfunded[funder] = 0;
        }
        s_funders = new address[](0);

        //second withdraw the fund. If sending native blockchain currency, there are 3 ways to do so: transfer, send and call
        //transfer
        payable(msg.sender).transfer(address(this).balance); //address(this) is also a type casting. this means the underlying smart contract. And address() to cast the type into the address of the contract.
        //send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "send failed");
        //call
        //(bool callSuccess, bytes memory dataReturn) = payable(msg.sender).call{value: address(this).balance}("");
        // we call the function(""), which is an empty function. (so we dont call any function for this case. )
        //also, while we call the empty function, we send some value aloong with the function call; the value =address(this).balance.
        //this returns 2 items. one is a bool representing if the function call was successful. the other is the return of the proper function, in this case, not matter.
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
        //using call is the recommended way!

        //new problem! anyone can call the function and take the fund. Solution use construct to define a owner and require owner to withdraw.
    }

    //what if someone send me eth without calling fund() function
    //receive(); this is a special type of function that I don't need to add special word function.
    //It is triggered when send eth directly instead of any other data (data here means call a contract etc.)
    receive() external payable {
        fund();
    }

    //fallback();this is a special type of function that I don't need to add special word function.
    //It is triggered when msg sender is calling on unknow data. eg 0x00
    fallback() external payable {
        fund();
    }

    //add some view/pure functions as getter function

    function getAddresstoAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addresstoamountfunded[fundingAddress];
    }

    function getFunder(uint256 Index) external view returns (address) {
        return s_funders[Index];
    }

    function getFunderLength() external view returns (uint256) {
        return s_funders.length;
    }

    function getOwnerAddress() external view returns (address) {
        return ownerAddress;
    }
}

// 1000000000000000
