// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //all have to be internal;
    function getprice(
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        //need address of the chainlink contract :0x694AA1769357215DE4FAC081bf1f309aDC325306
        //and abi

        (, int256 myanswer, , , ) = dataFeed.latestRoundData();
        return uint256(myanswer * 1e10);
    }

    function getversion() internal view returns (uint256) {
        uint256 version;
        // the logic was ABI(address).function(); ABI was obtained through interface compilation.
        return
            version = AggregatorV3Interface(
                0x694AA1769357215DE4FAC081bf1f309aDC325306
            ).version();
    }

    function getconversionrate(
        uint256 ETHAmount,
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        //uint256 EthPrice = 1889010000000000000000;
        uint256 EthPrice = getprice(dataFeed);
        //uint256 USDAmount = ((WeiAmount * EthPrice) / 1e18) / 1e8;
        //above is wrong because the all numbers in solidity are intergers. So some of the diovision will result a smaller than 1 number which will return a 0.
        uint256 USDAmount = (EthPrice * ETHAmount) / 1e18;
        return USDAmount;
    }
}
