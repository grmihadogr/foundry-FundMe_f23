// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        //In HelperConfig, I defined a struct called NetworkConfig and created an instance called activeNetworkConfig
        //if the struct have multiple items in it, the more thorough statement would be (assume 3 items, and the first item in the defination struct is the address I need.)
        //(address ethUSDPriceFeed, ,) = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUSDPriceFeed);
        //we want to create a fake chain that returm a price.
        //mock
        vm.stopBroadcast();
        return fundme;
    }
}
