// SPDX-License-Identifier: MIT

//we want to deploy mocks when we are on a local anvil chain
// keep track of contract address across different chain. eg Sepolia Mainnet ETH/USD
pragma solidity ^0.8.18;

//because this is a script, so we need to import the script base model
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //if we are on the local anvil chian, we deploy the mock
    //otherwise, grab the exsiting address from live chain

    //problem 1 for each of the config file, what if we need a lot of info, eg. price, gas price address etc.
    //solution: we create a type -- using keyword struct

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_Price = 2000 * 1e8;

    struct NetworkConfig {
        address priceFeed; //this is eth/usd price feed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111)
            activeNetworkConfig = getSopeliaEthConfig();
        else if (block.chainid == 1)
            activeNetworkConfig = getMainnetEthConfig();
        else activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    function getSopeliaEthConfig() public pure returns (NetworkConfig memory) {
        //we need to return price feed address;
        NetworkConfig memory sopeliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sopeliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //we need to return price feed address;
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // if the preicefeed contract is already avaiolable, we dont want another setup. So add
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_Price
        ); //# of argument of constructor function is required for the new instance.
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}

//   function getAnvilEthConfig() public returns (NetworkConfig memory) {
// if the preicefeed contract is already avaiolable, we dont want another setup. So add
//       if (activeNetworkConfig.priceFeed != address(0)) {
//         return activeNetworkConfig;
//   }
// not
// if (activeNetworkConfig.priceFeed() != address(0)) {
//   return activeNetworkConfig;
// }
