// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    uint256 private constant PRECISION_FACTOR = 10 ** 18;
    int256 private constant DECIMALS = 10 ** 10;

    // We make it a library because it's gas efficient (no deployment cost for libraries), we attach the functionalities directly to uint256 vars, great for pure and view funcs
    function getPriceInUSD(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData(); // Get only the answer from the price feed // answer is in USD $ with 8 decimals
        return uint256(answer * DECIMALS); // We multiply by 10^10 because the answer is in 8 decimals and we want to convert it to 18 decimals
            /* For example:
        1 ETH = 2000 USD
        priceFeed.latestRoundData().answer=200000000000
        return: 200000000000 * 10^10= 2000000000000000000000
        later we divide it by the 10**18 Precision factor to get 2000USD$
        */
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPriceInUSD(priceFeed);
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / PRECISION_FACTOR; // get the whole amount in ETH, multiply by the ETH price, and divide by the precision factor to make it in USD$
        return ethAmountInUSD;
    }
}
